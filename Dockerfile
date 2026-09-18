FROM node:20-bookworm

RUN apt-get update && \
    apt-get install -y git cmake build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN cmake -S llama.cpp-source -B llama.cpp-source/build \
    -DGGML_NATIVE=OFF \
    -DLLAMA_CURL=OFF

RUN cmake --build llama.cpp-source/build --config Release --target llama-server -j2

RUN chown -R node:node /app

USER node

EXPOSE 8080

CMD ["sh", "-c", "./llama.cpp-source/build/bin/llama-server -m ./models/Qwen3.5-0.8B-Q4_0.gguf --host 127.0.0.1 --port 8081 -c 4096 --reasoning-budget 0 & node server.js"]
