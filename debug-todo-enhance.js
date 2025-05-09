// Test script to debug the to-do list text enhancement issue
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import fetch from 'node-fetch';

// Get current file directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Sample Todo List in Quill Delta format
const todoListDelta = {
  ops: [
    { insert: "My To-Do List:" },
    { insert: "\n" },
    { insert: "Buy groceries" },
    { insert: "\n", attributes: { list: "unchecked" } },
    { insert: "Finish report" },
    { insert: "\n", attributes: { list: "unchecked" } },
    { insert: "Call mom" },
    { insert: "\n", attributes: { list: "unchecked" } }
  ]
};

// API endpoint to test
const API_URL = process.env.API_URL || 'http://localhost:3000';
const API_TOKEN = process.env.API_TOKEN || '';

// Function to extract list formatting information from a delta
function analyzeListFormatting(delta) {
  let listItems = 0;
  let hasUnchecked = false;
  let hasChecked = false;
  let hasBullet = false;
  
  if (!delta || !delta.ops) {
    return { listItems, hasUnchecked, hasChecked, hasBullet };
  }
  
  delta.ops.forEach(op => {
    if (op.insert === '\n' && op.attributes && op.attributes.list) {
      listItems++;
      if (op.attributes.list === 'unchecked') hasUnchecked = true;
      if (op.attributes.list === 'checked') hasChecked = true;
      if (op.attributes.list === 'bullet') hasBullet = true;
    }
  });
  
  return { listItems, hasUnchecked, hasChecked, hasBullet };
}

// Test the current behavior
async function testEnhancement() {
  console.log('Testing the enhance API with a to-do list...');
  
  try {
    // Analyze original delta
    const originalAnalysis = analyzeListFormatting(todoListDelta);
    console.log('Original delta analysis:');
    console.log(` - List items: ${originalAnalysis.listItems}`);
    console.log(` - Has unchecked: ${originalAnalysis.hasUnchecked}`);
    console.log(` - Has checked: ${originalAnalysis.hasChecked}`);
    console.log(` - Has bullet: ${originalAnalysis.hasBullet}`);
    
    // Call the API
    const response = await fetch(`${API_URL}/api/ai/enhance`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_TOKEN}`
      },
      body: JSON.stringify({
        content: todoListDelta,
        isQuillDelta: true
      })
    });
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status} ${response.statusText}`);
    }
    
    const result = await response.json();
    console.log('\nAPI Response:');
    console.log(JSON.stringify(result, null, 2));
    
    // Analyze enhanced delta
    const enhancedAnalysis = analyzeListFormatting(result.enhanced);
    console.log('\nEnhanced delta analysis:');
    console.log(` - List items: ${enhancedAnalysis.listItems}`);
    console.log(` - Has unchecked: ${enhancedAnalysis.hasUnchecked}`);
    console.log(` - Has checked: ${enhancedAnalysis.hasChecked}`);
    console.log(` - Has bullet: ${enhancedAnalysis.hasBullet}`);
    
    // Check if formatting was preserved
    console.log('\nFormatting preserved?', 
      enhancedAnalysis.listItems === originalAnalysis.listItems ? '✅ YES' : '❌ NO');
    
    return result;
  } catch (error) {
    console.error('Error testing enhancement:', error);
    throw error;
  }
}

// Run the test
testEnhancement()
  .then(() => console.log('Test completed'))
  .catch(error => console.error('Test failed:', error)); 