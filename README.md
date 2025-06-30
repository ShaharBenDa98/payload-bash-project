# Payload Bash Project

A fully interactive Bash script designed for educational use in lab environments.  
It automates the creation, packaging, and deployment of Metasploit payloads with smart logic, optional obfuscation, and instant delivery via a generated TinyURL.

---

## Features

- Interactively select payloads for Windows or Linux  
  - Choose from Top 10 or the full list  
- Prompts for all required options:  
  - LHOST, LPORT, EXITFUNC, etc.
- Handles staged vs. stageless payload logic automatically  
- Option to embed payload inside another executable  
- Optional ZIP compression and password protection  
- Apache auto-integration for instant web delivery  
- Generates a TinyURL for clean, shareable delivery  
- Auto-creates and runs a matching listener via `msfconsole -qx`

---

## Requirements

- Bash shell (Linux environment)
- Apache server (auto-handled by the script)
- Metasploit Framework (`msfvenom`, `msfconsole`)
- `curl` (for TinyURL API)
- fzf (for menu`s)
---

## Disclaimer

This project is built strictly for educational use in safe, isolated lab environments.  
Do not use it on any systems without explicit authorization.  
The author is not responsible for misuse.

---

## License

MIT — use it, learn from it, break it (in labs), and improve it.

---

## Credits

Thanks to David Shiffman (דוד שיפמן) for encouraging adversarial thinking to strengthen real-world defense.

