# Use the official Dart SDK image with a specific version
FROM dart:3.6.1 AS build

# Set the working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy the rest of the application code
COPY . .

# Run build_runner
RUN dart run build_runner build --delete-conflicting-outputs

# Build for production
RUN dart compile exe bin/main.dart -o server

# Use a minimal runtime image
FROM debian:bullseye-slim

# Set the working directory
WORKDIR /app

# Copy necessary files from build stage
COPY --from=build /app/server /app/
COPY --from=build /app/templates /app/templates
COPY --from=build /app/static /app/static

# Install required dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Expose the port
EXPOSE 8080

# Start the server
CMD ["./server"]
