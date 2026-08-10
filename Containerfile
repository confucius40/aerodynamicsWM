FROM rust:1-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libx11-dev \
    libxft-dev \
    libxcb1-dev \
    libxcb-util-dev \
    libxcb-xfixes0-dev \
    libxcb-render0-dev \
    libxcb-randr0-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY Cargo.toml Cargo.lock* ./

RUN mkdir -p src \
    && printf 'fn main() {}\n' > src/main.rs \
    && cargo build --release \
    && rm -rf src

COPY . .

RUN cargo build --release
