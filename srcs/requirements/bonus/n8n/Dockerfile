FROM debian:12

RUN apt-get update && \
    apt-get install -y \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install n8n
RUN npm install -g n8n

# Create n8n user
RUN useradd -m -s /bin/bash n8n

# n8n stores its data here
RUN mkdir -p /home/n8n/.n8n && \
    chown -R n8n:n8n /home/n8n

USER n8n

WORKDIR /home/n8n

EXPOSE 5678

CMD ["n8n", "start"]