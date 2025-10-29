# Having to sign-in everytime after sign-out or quit from menu bar - August 15, 2025

### Description
User is forced to go through complete onboarding process every time they quit and restart the app.

### Symptoms
- User quits app from menu bar (normal quit)
- Upon reopening, app shows sign-in screen
- Complete step-by-step onboarding process required again
- Authentication state not persisting

### User Quote
> "when i quit the app i am asked to sign in again and am taken through the step-by-step processs again :("

### Priority
🟠 **MEDIUM** - UX issue affecting user retention

### Expected Behavior
- Sign-in should persist between app sessions
- Only require re-authentication after explicit sign-out
- Skip onboarding for returning users

---

## Developer Notes
- User quit from menu bar (not force quit or crash)
- Both issues appear on fresh install
- User is patient and understanding
- Developer acknowledged complexity of desktop app debugging vs web apps

## Follow-up Actions
- [ ] Investigate CMD key recording pipeline
- [ ] Check audio permissions flow for new users
- [ ] Review authentication persistence logic
- [ ] Test quit/restart behavior
- [ ] Create reproduction steps for both issues