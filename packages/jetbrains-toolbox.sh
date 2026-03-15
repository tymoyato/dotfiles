#!/bin/bash

install_jetbrains_toolbox() {
	# Install JetBrains Toolbox on Linux
	print_message "Installing JetBrains Toolbox on Linux..." "instruction"
	check_curl
  #!/bin/bash

  URL=$(curl -s https://data.services.jetbrains.com/products/releases?code=TBA\&latest=true\&type=release \
    | jq -r '.TBA[0].downloads.linux.link')

  FILENAME=$(basename "$URL")

  echo "Downloading: $FILENAME"
  wget "$URL"

  echo "Extracting..."
  tar -xzf "$FILENAME"
  cd jetbrains-toolbox-*

  echo "Launching Toolbox..."
  ./jetbrains-toolbox
}
