class Verapdf < Formula
  desc "Industry supported, open source PDF/A validation GUI and CUI"
  homepage "https://software.verapdf.org/"
  url "https://github.com/veraPDF/veraPDF-apps/archive/refs/tags/v1.21.86.tar.gz"
  sha256 "c55075cc1f807c3841c394d62d4e320ae133d91174f966ea30c54609192f0119"
  license any_of: ["GPL-3.0-or-later", "MPL-2.0"]

  bottle do
    root_url "https://github.com/umireon/homebrew-verapdf/releases/download/verapdf-1.21.86"
    sha256 cellar: :any_skip_relocation, big_sur:      "1b9f696f3da38c2a39d3417fba04e8e87952a11dd7c7dc3334c906c55241abcf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f141d8d08de6d15277ee96174168a83d9ed7ce1e61975535544f8e0c911a2646"
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
