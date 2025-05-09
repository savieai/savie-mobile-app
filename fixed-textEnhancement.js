import openai from './openai.js';

const ENHANCEMENT_PROMPT = `
You are an AI assistant helping to enhance text notes. Your task is to:
1. Fix grammar and spelling errors
2. Improve clarity and readability
3. Organize information into paragraphs if needed
4. Maintain the original meaning and intent
5. Keep the same language as the input
6. IMPORTANT: Preserve the exact same number of paragraphs and line breaks as the original

Do NOT:
- Add new information not present in the original
- Change the style dramatically
- Make the text unnecessarily formal
- Add your own opinions or commentary
`;

export async function enhanceText(content, isQuillDelta = false) {
  try {
    console.log(`[DEBUG] enhanceText called with isQuillDelta=${isQuillDelta}`);
    
    if (!isQuillDelta) {
      // Original plain text implementation
      const response = await openai.chat.completions.create({
        model: process.env.AI_DEFAULT_MODEL || "gpt-4o-mini",
        messages: [
          { role: "system", content: ENHANCEMENT_PROMPT },
          { role: "user", content: content }
        ],
        temperature: 0.3,
      });
      
      return {
        enhanced: response.choices[0].message.content,
        original: content,
        format: 'plain'
      };
    } else {
      // Handle Quill Delta format
      let delta = typeof content === 'string' ? JSON.parse(content) : content;
      console.log('[DEBUG] Original delta:', JSON.stringify(delta));
      
      // Improved detection of formatted lists - check for any line with list attributes
      const isFormattedList = delta.ops && delta.ops.some(op => 
        (op.attributes && (
          op.attributes.list === 'checked' || 
          op.attributes.list === 'unchecked' || 
          op.attributes.list === 'bullet'
        )) || 
        (op.insert === '\n' && op.attributes && op.attributes.list)
      );
      
      // Detect todo embedding format
      const hasTodoEmbeds = delta.ops && delta.ops.some(op => 
        typeof op.insert === 'object' && op.insert && op.insert.todo !== undefined
      );
      
      // Enhanced detection: Count how many list items we have
      let listItemCount = 0;
      if (delta.ops) {
        delta.ops.forEach(op => {
          if (op.insert === '\n' && op.attributes && op.attributes.list) {
            listItemCount++;
            console.log(`[DEBUG] Found list item with attribute: ${op.attributes.list}`);
          }
        });
      }
      
      // Detect whether content looks like a to-do list based on text
      let plainText = '';
      if (delta.ops) {
        delta.ops.forEach(op => {
          if (typeof op.insert === 'string') {
            plainText += op.insert;
          }
        });
      }
      
      // Check if it contains todo-related keywords
      const todoKeywords = ['to do', 'todo', 'to-do', 'checklist', 'task list'];
      const looksLikeTodoList = todoKeywords.some(keyword => 
        plainText.toLowerCase().includes(keyword)
      );
      
      const shouldUseListPreservation = isFormattedList || hasTodoEmbeds || looksLikeTodoList;
      
      console.log(`[DEBUG] Detection results:
        - isFormattedList: ${isFormattedList}
        - hasTodoEmbeds: ${hasTodoEmbeds}
        - looksLikeTodoList: ${looksLikeTodoList}
        - listItemCount: ${listItemCount}
        - shouldUseListPreservation: ${shouldUseListPreservation}`);
      
      // Extract plain text and formatting info from Delta
      const { plainText: extractedText, formatMap, lineBreaks } = analyzeQuillDelta(delta);
      console.log('[DEBUG] Extracted plain text:', extractedText);
      
      // Enhance the extracted text
      const response = await openai.chat.completions.create({
        model: process.env.AI_DEFAULT_MODEL || "gpt-4o-mini",
        messages: [
          { role: "system", content: ENHANCEMENT_PROMPT },
          { role: "user", content: extractedText }
        ],
        temperature: 0.3,
      });
      
      const enhancedText = response.choices[0].message.content;
      console.log('[DEBUG] Enhanced text:', enhancedText);
      
      // Reapply formatting while preserving line breaks
      let enhancedDelta;
      
      // Use specialized handling for lists to ensure formatting integrity
      if (shouldUseListPreservation) {
        console.log("[DEBUG] Using specialized list formatting preservation");
        enhancedDelta = preserveListFormatting(delta, enhancedText);
      } else {
        // Standard approach for regular content
        console.log("[DEBUG] Using standard reconstruction");
        enhancedDelta = reconstructQuillDelta(enhancedText, formatMap, lineBreaks);
      }
      
      console.log('[DEBUG] Final enhanced delta:', JSON.stringify(enhancedDelta));
      
      return {
        enhanced: enhancedDelta,
        original: delta,
        format: 'delta'
      };
    }
  } catch (error) {
    console.error('Error enhancing text:', error);
    throw new Error(`Failed to enhance text: ${error.message}`);
  }
}

// Extract text and analyze formatting from Delta
function analyzeQuillDelta(delta) {
  let plainText = '';
  const formatMap = [];
  const lineBreaks = [];
  let currentPosition = 0;
  
  if (!delta.ops) {
    return { plainText, formatMap, lineBreaks };
  }
  
  delta.ops.forEach(op => {
    if (typeof op.insert === 'string') {
      // Check if this is a line break
      if (op.insert === '\n') {
        lineBreaks.push({
          position: currentPosition,
          attributes: op.attributes || {}
        });
        plainText += '\n';
        currentPosition += 1;
      } else {
        // Handle normal text
        plainText += op.insert;
        
        if (op.attributes) {
          formatMap.push({
            start: currentPosition,
            end: currentPosition + op.insert.length,
            attributes: op.attributes
          });
        }
        
        currentPosition += op.insert.length;
      }
    } else if (typeof op.insert === 'object') {
      // Handle embeds like images, videos, etc.
      plainText += ' ';  // Add a space as placeholder
      formatMap.push({
        start: currentPosition,
        end: currentPosition + 1,
        embed: op.insert,
        attributes: op.attributes
      });
      currentPosition += 1;
    }
  });
  
  return { plainText, formatMap, lineBreaks };
}

// Reconstruct Quill Delta from enhanced text and formatting info
function reconstructQuillDelta(enhancedText, formatMap, lineBreaks) {
  const newDelta = { ops: [] };
  
  // First, split the text at line breaks
  const textLines = enhancedText.split('\n');
  
  // Process each line
  textLines.forEach((line, index) => {
    // Apply any formatting to this line
    let lineStart = enhancedText.indexOf(line, index === 0 ? 0 : enhancedText.indexOf(textLines[index - 1]) + textLines[index - 1].length + 1);
    let lineEnd = lineStart + line.length;
    
    // Find formats that apply to this line
    let lineFormats = formatMap.filter(format => 
      (format.start <= lineEnd && format.end >= lineStart)
    );
    
    // If we have formats, apply them
    if (lineFormats.length > 0) {
      // Split the line according to different formats
      let currentPosition = lineStart;
      
      lineFormats.sort((a, b) => a.start - b.start);
      
      lineFormats.forEach(format => {
        // Add any text before this format
        if (format.start > currentPosition) {
          const plainPart = line.substring(currentPosition - lineStart, format.start - lineStart);
          if (plainPart) {
            newDelta.ops.push({ insert: plainPart });
          }
        }
        
        // Add the formatted part
        if (format.embed) {
          newDelta.ops.push({ 
            insert: format.embed,
            attributes: format.attributes 
          });
        } else {
          const formatStart = Math.max(format.start, lineStart);
          const formatEnd = Math.min(format.end, lineEnd);
          const formattedPart = line.substring(formatStart - lineStart, formatEnd - lineStart);
          
          if (formattedPart) {
            newDelta.ops.push({ 
              insert: formattedPart,
              attributes: format.attributes 
            });
          }
        }
        
        currentPosition = Math.max(currentPosition, format.end);
      });
      
      // Add any remaining text
      if (currentPosition < lineEnd) {
        const remainingPart = line.substring(currentPosition - lineStart);
        if (remainingPart) {
          newDelta.ops.push({ insert: remainingPart });
        }
      }
    } else {
      // No formatting, add the whole line
      if (line) {
        newDelta.ops.push({ insert: line });
      }
    }
    
    // Add line break if not the last line
    if (index < textLines.length - 1 || enhancedText.endsWith('\n')) {
      // Find matching line break
      const lineBreak = index < lineBreaks.length ? lineBreaks[index] : null;
      
      if (lineBreak && Object.keys(lineBreak.attributes).length > 0) {
        newDelta.ops.push({ 
          insert: '\n',
          attributes: lineBreak.attributes
        });
      } else {
        newDelta.ops.push({ insert: '\n' });
      }
    }
  });
  
  return newDelta;
}

// Simpler function that preserves line break attributes but doesn't try to be too clever
function replaceTextInDelta(delta, newText) {
  if (!delta.ops || delta.ops.length === 0) {
    return { ops: [{ insert: newText }] };
  }
  
  // Extract line break info from original delta
  const lineBreaks = [];
  let lineInserts = [];
  let lineBreakCount = 0;
  
  for (let i = 0; i < delta.ops.length; i++) {
    const op = delta.ops[i];
    if (typeof op.insert === 'string' && op.insert === '\n') {
      lineBreaks.push({
        index: lineBreakCount++,
        attributes: op.attributes || {}
      });
    } else if (typeof op.insert === 'string') {
      // Count line breaks in text content
      const breaks = op.insert.split('\n').length - 1;
      for (let j = 0; j < breaks; j++) {
        lineBreaks.push({
          index: lineBreakCount++,
          attributes: {}  // Inline breaks have no attributes
        });
      }
      
      // If this contains text content, gather for replacement
      if (op.insert.trim()) {
        lineInserts.push({
          text: op.insert,
          attributes: op.attributes
        });
      }
    }
  }
  
  // Split enhanced text by line breaks
  const enhancedLines = newText.split('\n');
  
  // Create new delta with enhanced text and preserved line breaks
  const newDelta = { ops: [] };
  
  enhancedLines.forEach((line, index) => {
    if (line) {
      newDelta.ops.push({
        insert: line,
        attributes: lineInserts.length > index % lineInserts.length 
          ? lineInserts[index % lineInserts.length].attributes 
          : undefined
      });
    }
    
    // Add line break if not the last line or if original ends with line break
    if (index < enhancedLines.length - 1 || newText.endsWith('\n')) {
      const lineBreak = lineBreaks[index] || { attributes: {} };
      
      if (Object.keys(lineBreak.attributes).length > 0) {
        newDelta.ops.push({ 
          insert: '\n',
          attributes: lineBreak.attributes
        });
      } else {
        newDelta.ops.push({ insert: '\n' });
      }
    }
  });
  
  return newDelta;
}

// Special function to preserve list formatting after enhancement
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
          console.log(`[DEBUG] Found list attribute at index ${index}:`, JSON.stringify(op.attributes));
          
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
  
  console.log(`[DEBUG] Found ${listAttributes.length} list attributes`);
  
  // Split the enhanced text into lines - trim the text to remove trailing newlines
  const enhancedTextTrimmed = enhancedText.trimEnd();
  const enhancedLines = enhancedTextTrimmed.split('\n');
  console.log(`[DEBUG] Enhanced text has ${enhancedLines.length} lines`);
  
  // Check if this is a list based on attributes or content
  const isList = listAttributes.length > 0 || defaultListAttribute !== null;
  console.log(`[DEBUG] Is this a list? ${isList}`);
  
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
      console.log(`[DEBUG] Identified title line: "${enhancedLines[0]}"`);
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
        console.log(`[DEBUG] Applied text formatting to line ${index}: ${JSON.stringify(matchingFormat.attributes)}`);
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
    if (!isLastLine || enhancedText.endsWith('\n')) {
      let attributeToUse = null;
      
      // Title line gets a regular line break, not list formatting
      if (index === titleLineIndex) {
        newDelta.ops.push({ insert: '\n' });
        console.log(`[DEBUG] Title line ${index} gets regular line break`);
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
            insert: '\n',
            attributes: attributeToUse
          });
          console.log(`[DEBUG] Applied list attribute to line ${index}:`, JSON.stringify(attributeToUse));
        } else {
          // Shouldn't happen but fallback
          newDelta.ops.push({ insert: '\n' });
          console.log(`[DEBUG] No list attribute available for line ${index}`);
        }
      } 
      // Regular line break for non-list or empty lines
      else {
        newDelta.ops.push({ insert: '\n' });
        console.log(`[DEBUG] Regular line break for line ${index}`);
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
          insert: '\n',
          attributes: attributeToUse
        });
        console.log(`[DEBUG] Applied list attribute to last line ${index}:`, JSON.stringify(attributeToUse));
      }
    }
  });
  
  // Final check: Add trailing newline if original text ended with one
  if (enhancedText.endsWith('\n') && !enhancedTextTrimmed.endsWith('\n')) {
    newDelta.ops.push({ insert: '\n' });
  }
  
  console.log("[DEBUG] Result Delta:", JSON.stringify(newDelta));
  return newDelta;
} 