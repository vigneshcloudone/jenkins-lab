FROM nginx:alpine
COPY . /usr/share/nginx/html
RUN echo "build $(date)"
