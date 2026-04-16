@echo off
setlocal

if not %JAVA_HOME% == "" goto OkJHome
echo Error: JAVA_HOME not found in your environment.
exit /b 1

:OkJHome
if exist %JAVA_HOME%\bin\java.exe goto init
echo Error: JAVA_HOME is set to an invalid directory.
exit /b 1

:init
set MAVEN_PROJECTBASEDIR=%CD%
set WRAPPER_JAR=%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar

%JAVA_HOME%\bin\java.exe %MAVEN_OPTS% %MAVEN_DEBUG_OPTS% -classpath %WRAPPER_JAR% -Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR% org.apache.maven.wrapper.MavenWrapperMain %*
if ERRORLEVEL 1 exit /b 1
exit /b 0
