# Use lightweight nginx image
FROM nginx:stable-alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy site content
COPY src/ /usr/share/nginx/html/

# (Optional) copy custom nginx config
# COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
# hjnkdfj

