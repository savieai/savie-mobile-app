import openai from './openai.js';

const TASK_EXTRACTION_PROMPT = `
You are an AI assistant helping to extract actionable tasks from notes. Your task is to:
1. Identify explicit or implicit tasks in the text
2. For each task, determine:
   - Task type (calendar, email, reminder, etc.)
   - Title (clear, concise description)
   - Details (relevant information like time, location, etc.)
   - People involved (names mentioned)

Return a JSON array of tasks with the following structure:
[
  {
    "type": "calendar|email|reminder|other",
    "title": "Task title",
    "details": {
      "start_time": "ISO datetime string (if applicable)",
      "end_time": "ISO datetime string (if applicable)",
      "location": "Location (if applicable)",
      "content": "Content for emails or other details"
    },
    "people": ["Name1", "Name2"]
  }
]

If no tasks are present, return an empty array: []
`;

/**
 * Extract tasks from text using OpenAI
 * 
 * @param {string} text The text to extract tasks from
 * @returns {Array} Array of tasks
 * 
 * Note: When this function is called from the /api/ai/extract-tasks endpoint,
 * the response will include:
 * - tasks: Array of extracted tasks with details
 * - calendar_connected: Boolean indicating if the user has an active Google Calendar connection
 * 
 * Example response:
 * {
 *   "tasks": [
 *     {
 *       "title": "Meeting with John",
 *       "type": "calendar",
 *       "details": {
 *         "start_time": "2023-06-15T14:00:00Z",
 *         "location": "Office"
 *       },
 *       "people": ["John"]
 *     }
 *   ],
 *   "calendar_connected": true
 * }
 */
export async function extractTasks(content) {
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        { role: "system", content: TASK_EXTRACTION_PROMPT },
        { role: "user", content: content }
      ],
      temperature: 0.2,
    });
    
    try {
      const result = JSON.parse(response.choices[0].message.content);
      return Array.isArray(result) ? result : [];
    } catch (e) {
      console.error('Error parsing task extraction result:', e);
      return [];
    }
  } catch (error) {
    console.error('Error extracting tasks:', error);
    throw new Error(`Failed to extract tasks: ${error.message}`);
  }
} 