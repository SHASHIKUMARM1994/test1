# Stage 1: Build sample.war using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /build

# Create minimal Java web app inline
RUN mkdir -p src/main/java/com/example \
    && mkdir -p src/main/webapp/WEB-INF

# Sample servlet (Java)
RUN echo 'package com.example; \
import java.io.*; \
import javax.servlet.*; \
import javax.servlet.http.*; \
public class HelloServlet extends HttpServlet { \
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException { \
    response.setContentType("text/html"); \
    response.getWriter().println("<h1>Hello World</h1>"); \
  } \
}' > src/main/java/com/example/HelloServlet.java

# web.xml
RUN echo '<?xml version="1.0" encoding="UTF-8"?> \
<web-app xmlns="http://jakarta.ee/xml/ns/jakartaee" version="5.0"> \
  <servlet> \
    <servlet-name>HelloServlet</servlet-name> \
    <servlet-class>com.example.HelloServlet</servlet-class> \
  </servlet> \
  <servlet-mapping> \
    <servlet-name>HelloServlet</servlet-name> \
    <url-pattern>/</url-pattern> \
  </servlet-mapping> \
</web-app>' > src/main/webapp/WEB-INF/web.xml

# Maven project file (pom.xml)
RUN echo '<project xmlns="http://maven.apache.org/POM/4.0.0" \
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 \
  http://maven.apache.org/xsd/maven-4.0.0.xsd"> \
  <modelVersion>4.0.0</modelVersion> \
  <groupId>com.example</groupId> \
  <artifactId>sample</artifactId> \
  <version>1.0</version> \
  <packaging>war</packaging> \
  <dependencies> \
    <dependency> \
      <groupId>jakarta.servlet</groupId> \
      <artifactId>jakarta.servlet-api</artifactId> \
      <version>5.0.0</version> \
      <scope>provided</scope> \
    </dependency> \
  </dependencies> \
</project>' > pom.xml

# Build WAR
RUN mvn package

# Stage 2: Deploy to Tomcat
FROM tomcat:10.1-jdk17-temurin

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR
COPY --from=builder /build/target/sample.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
