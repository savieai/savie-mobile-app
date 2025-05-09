// Script to fix the preserveListFormatting function in textEnhancement.js
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Get current file directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Path to the textEnhancement.js file
const filePath = path.join(__dirname, 'savie-mobile-backend', 'src', 'ai', 'textEnhancement.js');

// Read the file
console.log(`Reading file: ${filePath}`);
const fileContent = fs.readFileSync(filePath, 'utf8');

// Function to replace the preserveListFormatting function with a fixed version
function applyFix(content) {
  // Match the whole preserveListFormatting function
  const functionRegex = /(\/\/ Special function to preserve list formatting after enhancement[\s\S]*?export function preserveListFormatting[\s\S]*?})([\s\S]*\/\/ \.\.\.)/;
  
  // Fixed function implementation
  const fixedFunction = `// Special function to preserve list formatting after enhancement
export function preserveListFormatting(originalDelta, enhancedText) {
  // Extract the list formatting attributes from the original delta
  const listAttributes = [];
  let nonListOps = [];
  let defaultListAttribute = null;
  
  // Add debug logging
  console.log("[DEBUG] preserveListFormatting - Original Delta:", JSON.stringify(originalDelta));
  console.log("[DEBUG] preserveListFormatting - Enhanced Text:", enhancedText);
  
  // First pass: collect formatting info and find the dominant list type
  if (originalDelta.ops) {
    // Count attribute types to determine the default
    let checkedCount = 0;
    let uncheckedCount = 0;
    let bulletCount = 0;
    
    originalDelta.ops.forEach((op, index) => {
      if (typeof op.insert === 'string') {
        if (op.insert === '\n' && op.attributes && op.attributes.list) {
          // This is a list item line break (bullet, todo, etc)
          listAttributes.push(op.attributes);
          console.log(\`[DEBUG] Found list attribute at index \${index}:\`, JSON.stringify(op.attributes));
          
          // Count by type
          if (op.attributes.list === 'checked') checkedCount++;
          if (op.attributes.list === 'unchecked') uncheckedCount++;
          if (op.attributes.list === 'bullet') bulletCount++;
        } else if (op.insert !== '\n') {
          // Collect non-list ops for additional formatting
          if (op.attributes) {
            nonListOps.push({
              text: op.insert,
              attributes: op.attributes
            });
          }
        }
      }
    });
    
    // Determine default list attribute for consistency
    if (uncheckedCount >= checkedCount && uncheckedCount >= bulletCount) {
      defaultListAttribute = { list: 'unchecked' };
    } else if (bulletCount >= uncheckedCount && bulletCount >= checkedCount) {
      defaultListAttribute = { list: 'bullet' };
    } else if (checkedCount > 0) {
      defaultListAttribute = { list: 'checked' };
    }
    
    console.log("[DEBUG] Default list attribute:", JSON.stringify(defaultListAttribute));
  }
  
  // If we don't have any list attributes, but have clues this is a to-do list,
  // set a default of unchecked as fallback
  if (listAttributes.length === 0 && 
      (enhancedText.includes("To-Do") || 
       enhancedText.includes("To Do") || 
       enhancedText.includes("TODO"))) {
    defaultListAttribute = { list: 'unchecked' };
    console.log("[DEBUG] No list attributes found, but text suggests to-do list. Using default unchecked.");
  }
  
  console.log(\`[DEBUG] Found \${listAttributes.length} list attributes\`);
  
  // Split the enhanced text into lines - trim the text to remove trailing newlines
  const enhancedTextTrimmed = enhancedText.trimEnd();
  const enhancedLines = enhancedTextTrimmed.split('\\n');
  console.log(\`[DEBUG] Enhanced text has \${enhancedLines.length} lines\`);
  
  // Check if this is a list based on attributes or content
  const isList = listAttributes.length > 0 || defaultListAttribute !== null;
  console.log(\`[DEBUG] Is this a list? \${isList}\`);
  
  // If this is a list, identify the title line (if any) and content lines
  let titleLineIndex = -1;
  
  if (isList) {
    // First line is often a title if it doesn't have list attributes
    // and the second line has list formatting
    if (enhancedLines.length > 1 && 
        enhancedLines[0].trim().length > 0 &&
        (enhancedLines[0].includes("To-Do") || 
         enhancedLines[0].includes("To Do") || 
         enhancedLines[0].includes("TODO") ||
         enhancedLines[0].includes("List"))) {
      titleLineIndex = 0;
      console.log(\`[DEBUG] Identified title line: "\${enhancedLines[0]}"\`);
    }
  }
  
  const newDelta = { ops: [] };
  
  // Create new Delta with preserved list formatting
  enhancedLines.forEach((line, index) => {
    // Skip empty lines at the beginning
    if (index === 0 && !line.trim()) {
      return;
    }
    
    // Add the text content only if not empty
    if (line.trim()) {
      // Check if we have any text formatting to apply to this line
      const matchingFormat = nonListOps.find(op => line.includes(op.text));
      if (matchingFormat) {
        newDelta.ops.push({ 
          insert: line,
          attributes: matchingFormat.attributes
        });
        console.log(\`[DEBUG] Applied text formatting to line \${index}: \${JSON.stringify(matchingFormat.attributes)}\`);
      } else {
        newDelta.ops.push({ insert: line });
      }
    } else if (index < enhancedLines.length - 1) {
      // Empty line but not the last one - add it anyway
      newDelta.ops.push({ insert: line });
    }
    
    // Handle line breaks and list formatting
    const isLastLine = index === enhancedLines.length - 1;
    
    // Always add a line break for non-last lines or if the text ended with newline
    if (!isLastLine || enhancedText.endsWith('\\n')) {
      let attributeToUse = null;
      
      // Title line gets a regular line break, not list formatting
      if (index === titleLineIndex) {
        newDelta.ops.push({ insert: '\\n' });
        console.log(\`[DEBUG] Title line \${index} gets regular line break\`);
      } 
      // Apply list formatting to content lines in a list
      else if (isList && line.trim() && index > titleLineIndex) {
        // Determine which attribute to use
        if (index - (titleLineIndex >= 0 ? 1 : 0) < listAttributes.length) {
          // Use original attribute if available
          attributeToUse = listAttributes[index - (titleLineIndex >= 0 ? 1 : 0)];
        } else if (defaultListAttribute) {
          // Otherwise use default
          attributeToUse = defaultListAttribute;
        }
        
        // Apply list formatting
        if (attributeToUse) {
          newDelta.ops.push({
            insert: '\\n',
            attributes: attributeToUse
          });
          console.log(\`[DEBUG] Applied list attribute to line \${index}:\`, JSON.stringify(attributeToUse));
        } else {
          // Shouldn't happen but fallback
          newDelta.ops.push({ insert: '\\n' });
          console.log(\`[DEBUG] No list attribute available for line \${index}\`);
        }
      } 
      // Regular line break for non-list or empty lines
      else {
        newDelta.ops.push({ insert: '\\n' });
        console.log(\`[DEBUG] Regular line break for line \${index}\`);
      }
    } 
    // For the last line in the list, we need to ensure it also gets formatting
    else if (isLastLine && isList && line.trim() && index > titleLineIndex) {
      // This fixes the last list item which was missing formatting
      let attributeToUse = defaultListAttribute;
      
      // Use original attribute if available
      if (index - (titleLineIndex >= 0 ? 1 : 0) < listAttributes.length) {
        attributeToUse = listAttributes[index - (titleLineIndex >= 0 ? 1 : 0)];
      }
      
      if (attributeToUse) {
        // Add the line break with list formatting for the last line
        newDelta.ops.push({
          insert: '\\n',
          attributes: attributeToUse
        });
        console.log(\`[DEBUG] Applied list attribute to last line \${index}:\`, JSON.stringify(attributeToUse));
      }
    }
  });
  
  // Final check: Add trailing newline if original text ended with one
  if (enhancedText.endsWith('\\n') && !enhancedTextTrimmed.endsWith('\\n')) {
    newDelta.ops.push({ insert: '\\n' });
  }
  
  console.log("[DEBUG] Result Delta:", JSON.stringify(newDelta));
  return newDelta;
}`;

  // Replace the old function with the fixed one
  return content.replace(functionRegex, `${fixedFunction}$2`);
}

// Apply the fix
const fixedContent = applyFix(fileContent);

// Write the fixed content back to a new file for safety
const fixedFilePath = path.join(__dirname, 'fixed-textEnhancement.js');
fs.writeFileSync(fixedFilePath, fixedContent);

console.log(`Fixed file written to: ${fixedFilePath}`);
console.log('Please review the changes and if they look good, replace the original file.');

// Optional: Compare the files (summary of differences)
const originalLines = fileContent.split('\n').length;
const fixedLines = fixedContent.split('\n').length;
console.log(`\nComparison:
- Original file: ${originalLines} lines
- Fixed file: ${fixedLines} lines
- Difference: ${fixedLines - originalLines} lines added`);

// Check if the function was successfully replaced
console.log('\nChecking if fix was applied...');
if (fixedContent.includes('const isLastLine = index === enhancedLines.length - 1;')) {
  console.log('✅ Fix successfully applied!');
} else {
  console.log('⚠️ Fix may not have been applied correctly. Please check the fixed file.');
} 