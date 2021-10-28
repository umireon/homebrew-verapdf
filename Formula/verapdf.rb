class Verapdf < Formula
  desc "Industry supported, open source PDF/A validation GUI and CUI"
  homepage "https://software.verapdf.org/"
  url "https://github.com/veraPDF/veraPDF-apps/archive/refs/tags/v1.19.217.tar.gz"
  sha256 "3c8bdb9316191512b2eb884ac68f94d777b48acef56dcc3d9f18b453fa88211f"
  license any_of: ["GPL-3.0-or-later", "MPL-2.0"]

  bottle do
    root_url "https://github.com/umireon/homebrew-verapdf/releases/download/verapdf-1.19.217"
    sha256 cellar: :any_skip_relocation, catalina:     "ea051e88c5ee7bf2bcc800d36f5736ad471bb3e1d4afc83b150b18a35b5c1c34"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "67e8d25922d7498862d04229399d3f665a96c484d7417e897af1482b1ab4b3b1"
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
