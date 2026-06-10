# frozen_string_literal: true

require "json"
require "minitest/autorun"

class DefaultConfigTest < Minitest::Test
  CONFIG = JSON.parse(File.read(File.expand_path("../default.json", __dir__)))

  def test_config_does_not_allow_custom_post_upgrade_commands
    refute CONFIG.key?("allowedCommands")
  end

  def test_go_module_updates_use_builtin_go_mod_tidy
    rule = CONFIG.fetch("packageRules").find do |package_rule|
      package_rule.fetch("matchManagers", []).include?("gomod")
    end

    refute_nil rule
    return unless rule

    assert_equal ["gomodTidy"], rule.fetch("postUpdateOptions")
    refute rule.key?("postUpgradeTasks")
  end
end
