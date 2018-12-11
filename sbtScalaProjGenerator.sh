#!/bin/bash
#
# Default sbt file content, the name is the first parameter of the script, the project name too.
# Name:    sbtScalaProjGenerator
# Version: 0.1.0
# Author:  ainvar
# License: Creative Commons Attribution-ShareAlike 2.5 Generic
#          http://creativecommons.org/licenses/by-sa/2.5/


yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }


echo "I'm creating for u a scala sbt project !!"
buildSbt="\nname := \"$1\"

\nversion := \"0.1.0\"

\nscalaVersion := \"2.12.8\"

\nresolvers += \"Typesafe Repository\" at \"http://repo.typesafe.com/typesafe/releases/\"

\nscalacOptions ++= Seq(
    \n\t\"-deprecation\", // Emit warning and location for usages of deprecated APIs.
    \n\t\"-feature\", // Emit warning and location for usages of features that should be imported explicitly.
    \n\t\"-unchecked\", // Enable additional warnings where generated code depends on assumptions.
    \n\t\"-Xfatal-warnings\", // Fail the compilation if there are any warnings.
    \n\t\"-Xlint\", // Enable recommended additional warnings.
    \n\t\"-Ywarn-adapted-args\", // Warn if an argument list is modified to match the receiver.
    \n\t\"-Ywarn-dead-code\", // Warn when dead code is identified.
    \n\t\"-Ywarn-inaccessible\", // Warn about inaccessible types in method signatures.
    \n\t\"-Ywarn-nullary-override\", // Warn when non-nullary overrides nullary, e.g. def foo() over def foo.
    \n\t\"-Ywarn-numeric-widen\", // Warn when numerics are widened.
    \n\t\"-language:higherKinds\" // Enable the use of higher kinds by default
  \n)\n

"

sbtLibDep="libraryDependencies ++= Seq(
  // Testing
  \n\t\"org.scalatest\" %% \"scalatest\" % \"3.0.1\" % \"test\" withSources() withJavadoc()
  \n\t,\"org.scalacheck\" %% \"scalacheck\" % \"1.13.4\" % \"test\" withSources() withJavadoc()
  \n\t,\"org.mockito\" % \"mockito-all\" % \"1.10.19\" withSources()

  // Logging
  \n\t,\"com.typesafe.scala-logging\" %% \"scala-logging\" % \"3.5.0\" withSources()
  \n\t,\"ch.qos.logback\" % \"logback-classic\" % \"1.1.7\" withSources()
"


echo "$# parameters:";
echo Using '$*';
for p in $*;
do
    echo "[$p]";
done;

echo "\nSetting up the project... "
blnAkka=FALSE
blnPlay=FALSE
blnFx=FALSE
blnConsole=FALSE
blnHttp=FALSE
blnPlug=FALSE

for p in $@;
do
    echo "[$p]";
    case $p in
	    akka|AKKA|Akka) blnAkka=TRUE
	    ;;
	    play|PLAY|Play) blnPlay=TRUE
	    ;;
	    scalafx|SCALAFX|ScalaFx) blnFx=TRUE
	    ;;
	    console|CONSOLE|Console) blnConsole=TRUE
	    ;;
	    http|HTTP|Http) blnHttp=TRUE
	    ;;
	    withPlugins|WITHPLUGINS|withplugins) blnPlug=TRUE
	    ;;
	    \?) echo "Invalid option -$OPTARG" >&2
	    ;;
  	esac
done;


# Dinamic build.sbt section
if $blnAkka; then 
	sbtLibDep=$sbtLibDep"\n\t,\"com.typesafe.akka\" %% \"akka-actor\" % \"2.5.6\"
\n\t,\"com.typesafe.akka\" %% \"akka-testkit\" % \"2.5.6\""
	printf "Added AKKA!!\n";
fi

#if $blnPlay; then 

#fi

if $blnFx; then 
	sbtLibDep=$sbtLibDep"\n\t,\"org.scalafx\" %% \"scalafx\" % \"8.0.102-R11\""
	printf "Added ScalaFX!!\n";
fi

if $blnHttp; then 
	sbtLibDep=$sbtLibDep"\n\t,\"com.typesafe.akka\" %% \"akka-http\" % \"10.0.10\""
	printf "Added akka http!!\n";
fi

sbtLibDep=$sbtLibDep")"

if $blnConsole; then 
	sbtLibDep=$sbtLibDep"\nmainClass in assembly := Some(\"Main\")"
	printf "Added MAIN class\n";
fi

# -------------------------
# 
# Dynamic plugins.sbt section
#Default
plugins="\naddSbtPlugin(\"com.lucidchart\" % \"sbt-scalafmt\" % \"1.10\")"

plugins=$plugins"\naddSbtPlugin(\"com.typesafe.sbt\" % \"sbt-native-packager\" % \"1.2.2\")\n"

plugins=$plugins"\naddSbtPlugin(\"org.scoverage\" % \"sbt-scoverage\" % \"1.5.1\")\n"

plugins=$plugins"\naddSbtPlugin(\"com.eed3si9n\" % \"sbt-buildinfo\" % \"0.7.0\")\n"

plugins=$plugins"\naddSbtPlugin(\"com.typesafe.sbt\" % \"sbt-git\" % \"0.9.3\")\n"

plugins=$plugins"\naddSbtPlugin(\"com.timushev.sbt\" % \"sbt-updates\" % \"0.3.1\")\n"

if $blnConsole; then 
	plugins=$plugins"\naddSbtPlugin(\"com.eed3si9n\" % \"sbt-assembly\" % \"0.14.5\")"
	printf "Added plugin for console app!\n";
fi

#folder tree

mkdir -p $1/src/{main,test}/{java,resources,scala}
mkdir $1/lib $1/project $1/target
mkdir -p $1/src/main/config
mkdir -p $1/src/{main,test}/{filters,assembly}
mkdir -p $1/src/site

# Files
# build.properties SBT version default 1.0.3
echo "sbt.version=1.2.7"  > $1/project/build.properties

# .gitignore
echo "# Sbt / Play
play/logs/
play/target/
project/project/*
project/target/*
target/

# Intelij Idea
.idea/

# Scala IDE
.classpath
.project
.settings/

# Git
**/*.orig

# Mac OS
.DS_Store

# Binaries
*.class
*.pyc

# Ensime
.ensime
.ensime_cache" > $1/.gitignore

# readme
touch $1/README.md

# build.sbt
echo -e $buildSbt$sbtLibDep > $1/build.sbt

# plugins.sbt

echo -e $plugins > $1/project/plugins.sbt

if $blnConsole; then 
echo "
object Main extends App {

}
" > $1/src/main/scala/Main.scala
fi


#add usufull plugins - not used
#if $blnPlug; then 

#fi

#echo "ALTRA TECNICA:"
#
#while getopts ":a:p:" opt; do
#  case $opt in
#    a) arg_1="$OPTARG"
#    ;;
#    p) p_out="$OPTARG"
#    ;;
#    \?) echo "Invalid option -$OPTARG" >&2
#    ;;
#  esac
#done
#
#printf "Argument p_out is %s\n" "$p_out"
#printf "Argument arg_1 is %s\n" "$arg_1"

