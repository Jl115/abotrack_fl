# Cloud Backup Enhancement Plan

## Current State
- ✅ Basic backup to SharedPreferences (JSON)
- ✅ Timestamp tracking
- ✅ Auto-backup toggle
- ❌ Restore doesn't actually add to controller
- ❌ No file export/import
- ❌ UI references Google Drive but uses local storage

## Enhancements to Build

### 1. CloudBackupService Improvements
- [x] Fix restore to actually call controller.addAbo()
- [ ] Add file export (JSON to device storage)
- [ ] Add file import (read JSON from device)
- [ ] Add backup validation
- [ ] Add backup size calculation

### 2. UI Improvements
- [ ] Update messaging (remove "Google Drive" references, use "Local Backup")
- [ ] Add export to file button
- [ ] Add import from file button
- [ ] Show last backup date & size
- [ ] Add backup confirmation dialog

### 3. Integration
- [ ] Hook up to background task manager for auto-backup
- [ ] Add backup on app close (optional)

## Implementation Order
1. Fix restore functionality (critical bug)
2. Add file export/import
3. Update UI with correct messaging
4. Test end-to-end
