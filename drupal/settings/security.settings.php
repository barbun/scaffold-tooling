<?php

// @codingStandardsIgnoreFile

/**
 * Modules allow list for GovCMS module_permissions.
 */
$config['module_permissions.settings']['managed_modules'] = [
  'bigmenu',
  'block_content',	
  'captcha',
  'ctools_block',
  'ctools_views',
  'chosen',
  'chosen_field',
  'chosen_lib',
  'components',
  'contact_storage',
  'context',
  'context_ui',
  'crop',
  'search_api_db',
  'search_api_db_defaults',
  'datetime',
  'datetime_range',
  'dropzonejs',
  'dropzonejs_eb_widget',
  'dynamic_entity_reference',
  'embed',
  'entity_browser',
  'entity_browser_entity_form',
  'entity_class_formatter',
  'entity_embed',
  'entity_reference',
  'entity_reference_display',
  'entity_reference_revisions',
  'environment_indicator',
  'environment_indicator_ui',
  'facets',
  'facets_range_widget',
  'field_group',
  'field_ui',
  'file',
  'focal_point',
  'govcms_dlm',
  'basic_auth',
  'image',
  'image_captcha',
  'inline_entity_form',
  'jquery_ui',
  'link',
  'linked_field',
  'linkit',
  'mailsystem',
  'media_entity_file_replace',
  'menu_block',
  'menu_trail_by_path',
  'metatag',
  'minisite',
  'options',
  'paragraphs',
  'pathauto',
  'shield',
  'recaptcha',
  'redirect',
  'redirect_404',
  'redirect_domain',
  'robotstxt',
  'role_delegation',
  'scheduled_transitions',
  'search_api',
  'search_api_attachments',
  'search_api_solr',
  'token',
  'webform',
  'webform_access',
  'webform_attachment',
  'webform_image_select',
  'webform_node',
  'webform_ui',
];

/**
 * Modules protected/disallow list for GovCMS module_permissions.
 */
$config['module_permissions.settings']['protected_modules'] = [
  'module_permissions',
  'module_permissions_ui',
];

/**
 * Permissions disallow list for GovCMS module_permissions.
 */
$config['module_permissions.settings']['permission_blacklist'] = [
  'administer modules',
  'administer permissions',
  'administer search_api',
  'assign all roles',
];

/**
* Event log track settings.
*/
// Disable Logging to DB
$config['event_log_track.adminsettings']['disable_db_logs'] = 1;
// Lock down event log output type.
$config['event_log_track.settings']['output_type'] = 'watchdog';

/**
 * Seckit configuration.
 */
// Enforce the GoVCMS report URI route.
$report_uri = getenv('GOVCMS_CSP_URI');
if (!empty($report_uri)) {
  $config['seckit.settings']['seckit_xss']['csp']['report-uri'] = $report_uri;
}
