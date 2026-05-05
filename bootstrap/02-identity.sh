# shellcheck shell=bash
# shellcheck disable=SC2154  # vars (BLUE, etc.) come from bootstrap/lib.sh
# bootstrap/02-identity.sh — Phase 2: identity (interactive — these need you).

phase "Phase 2: Identity"

step "1Password.app sign-in"
if op account list 2>/dev/null | grep -q .; then
  ok "1Password CLI already integrated and signed in"
else
  box "ACTION NEEDED: sign in to 1Password" \
    "" \
    "Opening 1Password.app. Sign in with your master password" \
    "and Secret Key. When done, leave 1Password running and" \
    "come back here." \
    ""
  open -a "1Password" || warn "couldn't open 1Password.app — open it manually"
  prompt_done

  box "ACTION NEEDED: enable 1Password CLI integration" \
    "" \
    "In 1Password.app:" \
    "  Settings → Developer → toggle 'Integrate with 1Password CLI'" \
    "" \
    "Optional: also enable 'Use Touch ID to unlock' on the same page" \
    "for fingerprint authentication." \
    ""
  warn "waiting for the integration to come online (poll every 5s)..."
  while ! op account list 2>/dev/null | grep -q .; do sleep 5; done
  ok "1Password CLI integrated"
fi

step "GitHub authentication"
if gh auth status >/dev/null 2>&1; then
  ok "gh already authenticated"
else
  box "ACTION NEEDED: authenticate gh" \
    "" \
    "Launching 'gh auth login'. Follow the browser flow:" \
    "  1. Copy the 8-character code shown in the terminal" \
    "  2. Paste it in the browser tab that opens" \
    "  3. Authorize the device" \
    ""
  prompt_continue
  gh auth login --hostname github.com --git-protocol https --web
  ok "gh authenticated"
fi
# Ensure git uses gh's credential helper from now on (idempotent).
gh auth setup-git >/dev/null 2>&1 || true

step "App Store sign-in (optional, needed for MAS apps)"
if mas account >/dev/null 2>&1; then
  ok "already signed in to App Store"
elif command -v mas >/dev/null 2>&1 && mas list >/dev/null 2>&1; then
  ok "App Store accessible (mas can list installed apps)"
else
  box "ACTION NEEDED: sign in to App Store (or skip)" \
    "" \
    "Opening App Store.app. Sign in with your Apple ID, then" \
    "return here." \
    "" \
    "If you don't want any Mac App Store apps, just press ENTER" \
    "to skip — bootstrap will continue and the MAS lines in the" \
    "Brewfile will warn but not fail." \
    ""
  open -a "App Store" || warn "couldn't open App Store.app — open it manually"
  prompt_done
fi
