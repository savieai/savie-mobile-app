# Testing Guide: Calendar Connectivity Check in Task Extraction

This guide outlines the steps to test the new `calendar_connected` field in the `/api/ai/extract-tasks` endpoint.

## Prerequisites

1. Ensure you have the latest backend code pulled and installed
2. Set up your environment variables in `.env` file:
   - `API_KEY`: Your API key for authentication
   - `API_URL`: The API base URL (default: http://localhost:3000)

## Automated Testing

Run the automated test script:

```bash
npm run test:task-extraction
```

This will:
- Make multiple requests to the endpoint with different content
- Verify the `calendar_connected` field is present in the response
- Check if tasks are correctly identified based on the content

## Manual Testing

### Test Case 1: With Google Calendar Connected

1. Ensure you have a Google Calendar connection set up for your test user
   - Check the `service_connections` table to confirm
   - There should be a record with `provider: 'google'` and `is_active: true`

2. Make a POST request to `/api/ai/extract-tasks`:
   ```bash
   curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -d '{"content": "Meet with John tomorrow at 2pm"}' \
     http://localhost:3000/api/ai/extract-tasks
   ```

3. Verify the response:
   - `calendar_connected` should be `true`
   - `tasks` array should contain a calendar task

### Test Case 2: Without Google Calendar Connected

1. Temporarily disconnect Google Calendar for your test user:
   - Update the `service_connections` table 
   - Set `is_active: false` for records with `provider: 'google'`

2. Make the same POST request as in Test Case 1

3. Verify the response:
   - `calendar_connected` should be `false`
   - `tasks` array should still contain a calendar task (extraction works regardless of connection)

4. Restore the connection status when testing is complete

### Test Case 3: No Calendar Tasks in Content

1. Make a POST request with content that doesn't mention calendar events:
   ```bash
   curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -d '{"content": "Remember to buy milk"}' \
     http://localhost:3000/api/ai/extract-tasks
   ```

2. Verify the response:
   - `calendar_connected` should reflect the actual connection status
   - `tasks` array should contain a non-calendar task (e.g., type: "todo")

## Frontend Integration Testing

After backend tests are successful, test the frontend integration:

1. Find places in the frontend code where task extraction results are handled
2. Update the code to check the `calendar_connected` field when calendar tasks are detected
3. Test different UI states based on the connection status:
   - Connected: Show task execution button
   - Not connected: Show connection prompt

## Success Criteria

- ✅ The `/api/ai/extract-tasks` endpoint consistently returns the `calendar_connected` field
- ✅ The value correctly reflects the user's Google Calendar connection status
- ✅ All existing functionality continues to work without issues
- ✅ Frontend shows appropriate UI based on the connection status 