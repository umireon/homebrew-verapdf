class Verapdf < Formula
  desc "Industry supported, open source PDF/A validation GUI and CUI"
  homepage "https://software.verapdf.org/"
  url "https://github.com/veraPDF/veraPDF-apps/archive/refs/tags/v1.19.206.tar.gz"
  sha256 "879996826c8bae0c9fd2c6f54226c7cdb581d2363869592c44aeec960620e815"
  license any_of: ["GPL-3.0-or-later", "MPL-2.0"]

  bottle do
    root_url "https://github.com/umireon/homebrew-verapdf/releases/download/verapdf-1.19.206"
    sha256 cellar: :any_skip_relocation, catalina:     "c314ca8a7146361f0f92c3cb77e6540525f50afe1cb973791f318b17359bd5f0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1be6da77fafd41a891441b62e11ec2f7654745d155489ff1e9c13ed665967d25"
  end

  depends_on "maven" => :build
  depends_on "openjdk@11"

  def install
    ENV["JAVA_HOME"] = Formula["openjdk@11"].opt_prefix

    system "mvn", "--projects", "greenfield-apps,gui", "clean", "package"
    libexec.install Dir["greenfield-apps/target/greenfield-apps-*-SNAPSHOT.jar"].first => "greenfield-apps-#{version}.jar"
    (bin/"verapdf").write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Language::Java.overridable_java_home_env("11")[:JAVA_HOME]}"
      exec "${JAVA_HOME}/bin/java" -classpath "#{libexec/"greenfield-apps-#{version}.jar"}" org.verapdf.apps.GreenfieldCliWrapper "$@"
    EOS
    (bin/"verapdf-gui").write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Language::Java.overridable_java_home_env("11")[:JAVA_HOME]}"
      exec "${JAVA_HOME}/bin/java" -classpath "#{libexec/"greenfield-apps-#{version}.jar"}" org.verapdf.apps.GreenfieldGuiWrapper --frameScale 1.0 "$@"
    EOS
  end

  test do
    system bin/"verapdf", "--version"
  end
end
