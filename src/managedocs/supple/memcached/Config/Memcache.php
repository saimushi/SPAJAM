<?php
return array (
  'stats_api' => 'Server',
  'slabs_api' => 'Server',
  'items_api' => 'Server',
  'get_api' => 'Server',
  'set_api' => 'Server',
  'delete_api' => 'Server',
  'flush_all_api' => 'Server',
  'connection_timeout' => '1',
  'max_item_dump' => '100',
  'refresh_rate' => 5,
  'memory_alert' => '80',
  'hit_rate_alert' => '90',
  'eviction_alert' => '0',
  'file_path' => 'Temp/',
  'servers' =>
  array (
    'Default' =>
    array (
      'テストサーバ' =>
      array (
        'hostname' => '10.0.100.222',
        'port' => '11211',
      ),
      '本番サーバ' =>
      array (
        'hostname' => 'kanokare-memcache.noi5px.0001.apne1.cache.amazonaws.com',
        'port' => '11211',
      ),
    ),
  ),
);