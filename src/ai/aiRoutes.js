import express from 'express';
// AI routes for text enhancement, task extraction, audio transcription, etc.
import { enhanceText } from './textEnhancement.js';
import { extractTasks } from './taskExtraction.js';
import { createClient } from '@supabase/supabase-js';
import multer from 'multer';
import path from 'path';
import { transcribeAudio } from './transcription.js';
import fs from 'fs';

const router = express.Router();
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SECRET_KEY
);

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const tempDir = path.join(process.cwd(), 'temp');
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }
    cb(null, tempDir);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Enhance text endpoint
router.post('/enhance', async (req, res) => {
  try {
    const { content } = req.body;
    const { currentUser } = res.locals;
    
    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }
    
    // Check rate limits
    const today = new Date().toISOString().split('T')[0];
    const { count } = await supabase
      .from('ai_usage')
      .select('*', { count: 'exact' })
      .eq('user_id', currentUser.sub)
      .eq('feature', 'enhance')
      .gte('used_at', `${today}T00:00:00`)
      .lte('used_at', `${today}T23:59:59`);
      
    if (count >= 100) {
      return res.status(429).json({ 
        error: 'Rate limit exceeded',
        message: 'You have exceeded your daily limit for text enhancement'
      });
    }
    
    // Enhance text
    const enhanced = await enhanceText(content);
    
    // Track usage
    await supabase.from('ai_usage').insert({
      user_id: currentUser.sub,
      feature: 'enhance',
    });
    
    return res.json(enhanced);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
});

// Extract tasks endpoint
router.post('/extract-tasks', async (req, res) => {
  try {
    const { content, message_id } = req.body;
    const { currentUser } = res.locals;
    
    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }
    
    // Check rate limits
    const today = new Date().toISOString().split('T')[0];
    const { count } = await supabase
      .from('ai_usage')
      .select('*', { count: 'exact' })
      .eq('user_id', currentUser.sub)
      .eq('feature', 'extract_tasks')
      .gte('used_at', `${today}T00:00:00`)
      .lte('used_at', `${today}T23:59:59`);
      
    if (count >= 100) {
      return res.status(429).json({ 
        error: 'Rate limit exceeded',
        message: 'You have exceeded your daily limit for task extraction'
      });
    }
    
    // Extract tasks
    const tasks = await extractTasks(content);
    
    // Track usage
    await supabase.from('ai_usage').insert({
      user_id: currentUser.sub,
      feature: 'extract_tasks',
    });
    
    // Save tasks to database if message_id is provided
    if (message_id && tasks.length > 0) {
      const tasksToInsert = tasks.map(task => ({
        user_id: currentUser.sub,
        message_id,
        title: task.title,
        type: task.type,
        details: task.details,
        people: task.people || [],
      }));
      
      await supabase.from('tasks').insert(tasksToInsert);
      
      // Update message
      await supabase
        .from('messages')
        .update({ tasks_extracted: true })
        .eq('id', message_id);
    }
    
    // Check if user has an active Google Calendar connection
    const { data: connections, error: connError } = await supabase
      .from('service_connections')
      .select('*')
      .eq('user_id', currentUser.sub)
      .eq('provider', 'google')
      .eq('is_active', true);
    
    // Set calendar_connected to true if any active Google connection exists
    // This matches the logic in hasServiceConnection function for calendar service
    const calendar_connected = connections && connections.length > 0;
    
    return res.json({ 
      tasks,
      calendar_connected
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
});

// Transcribe audio endpoint
router.post('/transcribe', upload.single('file'), async (req, res) => {
  try {
    const file = req.file;
    const { currentUser } = res.locals;
    
    if (!file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    
    // Check rate limits
    const today = new Date().toISOString().split('T')[0];
    const { count } = await supabase
      .from('ai_usage')
      .select('*', { count: 'exact' })
      .eq('user_id', currentUser.sub)
      .eq('feature', 'transcribe')
      .gte('used_at', `${today}T00:00:00`)
      .lte('used_at', `${today}T23:59:59`);
      
    if (count >= 50) {
      return res.status(429).json({ 
        error: 'Rate limit exceeded',
        message: 'You have exceeded your daily limit for audio transcription'
      });
    }
    
    // Transcribe audio
    const { transcription } = await transcribeAudio(file.path, currentUser.sub);
    
    // Clean up temp file
    fs.unlinkSync(file.path);
    
    return res.json({ transcription });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
});

export default router; 