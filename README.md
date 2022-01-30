# discbin.sh
discbin.sh is a convenient bash shellscript to upload files (and pipes!) from the terminal to Discord using webhooks. Upon upload, you will also receive the CDN url, ready for easy sharing.

# Features

- Standalone (does not require a server or service).
- Lightweight and simple.
- Upload files with custom names.
- Upload multiple files at once.
- Upload files from stdin (pipe).
- Get CDN links of the uploads.

# Usage

```bash
Options:
  -h, --help                  Prints this message.
  -f, --filename <filename>   Use a custom filename for the uploaded file.
  -w, --webhook <URL>         Set the webhook URL.
                              Note: The webhook URL can also be set by
                              using the DISCBIN_WEBHOOK env variable
                              or hardcoding it into the shellscript.
  -v, --verbose               Verbose jq json output.
Examples:
  # Upload a file
  discbin.sh dog.jpg
  # Upload a file with a custom filename
  discbin.sh dogs.zip -f cats.zip
  # Upload multiple files
  discbin.sh logo.png logo.svg
  discbin.sh *.mp3
  # Upload piped content as a file
  fortune | discbin.sh
  ls | discbin.sh -f files.txt
```

# Example

Commands entered:  
![example_term](img/example_term.png?raw=true)

Result on Discord:  
![example_disc](img/example_disc.png?raw=true)



# Setup

## Install

1. Go to a location in your PATH (eg `cd ~/.local/bin`).
2. Download the script (`wget https://raw.githubusercontent.com/rebane2001/discbin.sh/mane/discbin.sh`).
3. Allow executing the script (`chmod +x discbin.sh`).

You should now be able to use the `discbin.sh` command from anywhere.

## Webhook

1. In your Discord server, go to `Server Settings->Integrations->Webhooks`.
2. Click `New Webhook`.
3. (optional) Customize the name, avatar, and channel of the webhook.
4. Click `Copy Webhook URL`.
5. Use the URL with the script in one of three ways:
    - Add the webhook env variable into your profile, eg:  
     `echo 'export DISCBIN_WEBHOOK="https://discord.com/api/webhooks..."' >> ~/.bashrc && source ~/.bashrc`
    - Use the --webhook parameter every time, eg `discbin.sh --webhook "https://discord.com/api/webhooks..."`.
    - Hardcode the webhook URL into the shellscript itself.

You should now be able to use `discbin.sh` with your webhook.
