# frozen_string_literal: true

require "json"
require "minitest/autorun"

class DefaultConfigTest < Minitest::Test
  CONFIG = JSON.parse(File.read(File.expand_path("../default.json", __dir__)))

  def test_allowed_commands_cover_shared_post_upgrade_tasks
    commands = CONFIG.fetch("allowedCommands", [])

    assert_includes commands, "^go mod tidy$"
    assert_includes commands, "^\\./scripts/terraform-locks-update\\.sh$"
  end

  def test_go_module_updates_run_go_mod_tidy
    rule = CONFIG.fetch("packageRules").find do |package_rule|
      package_rule.fetch("matchManagers", []).include?("gomod")
    end

    refute_nil rule
    return unless rule

    tasks = rule.fetch("postUpgradeTasks")
    assert_equal "update", tasks.fetch("executionMode")
    assert_equal ["go mod tidy"], tasks.fetch("commands")
    assert_equal "{{{packageFileDir}}}", tasks.fetch("workingDirTemplate")
    assert_equal({ "golang" => {} }, tasks.fetch("installTools"))

    file_filters = tasks.fetch("fileFilters")
    assert_includes file_filters, "go.mod"
    assert_includes file_filters, "go.sum"
    assert_includes file_filters, "**/go.mod"
    assert_includes file_filters, "**/go.sum"
  end
end
