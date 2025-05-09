// Direct test script for textEnhancement.js
import { enhanceText, preserveListFormatting } from './savie-mobile-backend/src/ai/textEnhancement.js';

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

// Function to extract list formatting information from a delta
function analyzeListFormatting(delta) {
  let listItems = 0;
  let hasUnchecked = false;
  let hasChecked = false;
  let hasBullet = false;
  let structure = [];
  
  if (!delta || !delta.ops) {
    return { listItems, hasUnchecked, hasChecked, hasBullet, structure };
  }
  
  delta.ops.forEach(op => {
    if (op.insert === '\n' && op.attributes && op.attributes.list) {
      listItems++;
      if (op.attributes.list === 'unchecked') hasUnchecked = true;
      if (op.attributes.list === 'checked') hasChecked = true;
      if (op.attributes.list === 'bullet') hasBullet = true;
      structure.push({ type: 'list-break', format: op.attributes.list });
    } else if (typeof op.insert === 'string') {
      if (op.insert === '\n') {
        structure.push({ type: 'break' });
      } else {
        structure.push({ type: 'text', content: op.insert });
      }
    }
  });
  
  return { listItems, hasUnchecked, hasChecked, hasBullet, structure };
}

// Mocking the OpenAI call to return predictable text
function mockEnhanceText(text) {
  // Simple enhancement: capitalize first letter of each sentence
  return text.split('. ')
    .map(sentence => {
      if (!sentence) return '';
      return sentence.charAt(0).toUpperCase() + sentence.slice(1);
    })
    .join('. ');
}

// Test preserveListFormatting directly
async function testPreserveListFormatting() {
  console.log('Testing preserveListFormatting function directly...');
  
  try {
    // Extract the text from the delta for enhancement
    let plainText = '';
    todoListDelta.ops.forEach(op => {
      if (typeof op.insert === 'string') {
        plainText += op.insert;
      }
    });
    
    console.log('Extracted plain text:', plainText);
    
    // Simulate enhancement
    const enhancedText = mockEnhanceText(plainText);
    console.log('Enhanced text:', enhancedText);
    
    // Apply preserveListFormatting
    const enhancedDelta = preserveListFormatting(todoListDelta, enhancedText);
    console.log('Enhanced delta:', JSON.stringify(enhancedDelta, null, 2));
    
    // Analyze original and enhanced deltas
    const originalAnalysis = analyzeListFormatting(todoListDelta);
    const enhancedAnalysis = analyzeListFormatting(enhancedDelta);
    
    console.log('\nOriginal delta analysis:');
    console.log(` - List items: ${originalAnalysis.listItems}`);
    console.log(` - Structure: ${JSON.stringify(originalAnalysis.structure)}`);
    
    console.log('\nEnhanced delta analysis:');
    console.log(` - List items: ${enhancedAnalysis.listItems}`);
    console.log(` - Structure: ${JSON.stringify(enhancedAnalysis.structure)}`);
    
    console.log('\nFormatting preserved?', 
      enhancedAnalysis.listItems === originalAnalysis.listItems ? '✅ YES' : '❌ NO');
    
    return enhancedDelta;
  } catch (error) {
    console.error('Error testing preserveListFormatting:', error);
    throw error;
  }
}

// Test the full enhanceText function
async function testEnhanceText() {
  console.log('\nTesting full enhanceText function...');
  
  try {
    // Mock response for testing
    global.openai = {
      chat: {
        completions: {
          create: async () => ({
            choices: [{
              message: {
                content: mockEnhanceText(
                  todoListDelta.ops
                    .filter(op => typeof op.insert === 'string')
                    .map(op => op.insert)
                    .join('')
                )
              }
            }]
          })
        }
      }
    };
    
    // Call enhanceText with the todo list delta
    const result = await enhanceText(todoListDelta, true);
    console.log('EnhanceText result:', JSON.stringify(result, null, 2));
    
    // Analyze result
    const originalAnalysis = analyzeListFormatting(todoListDelta);
    const enhancedAnalysis = analyzeListFormatting(result.enhanced);
    
    console.log('\nOriginal delta analysis:');
    console.log(` - List items: ${originalAnalysis.listItems}`);
    
    console.log('\nEnhanced delta analysis:');
    console.log(` - List items: ${enhancedAnalysis.listItems}`);
    
    console.log('\nFormatting preserved in enhanceText?', 
      enhancedAnalysis.listItems === originalAnalysis.listItems ? '✅ YES' : '❌ NO');
    
    return result;
  } catch (error) {
    console.error('Error testing enhanceText:', error);
    throw error;
  }
}

// Run tests
async function runTests() {
  try {
    await testPreserveListFormatting();
    // Uncomment to test the full enhanceText function
    // await testEnhanceText();
    console.log('\nAll tests completed');
  } catch (error) {
    console.error('Test suite failed:', error);
  }
}

runTests(); 