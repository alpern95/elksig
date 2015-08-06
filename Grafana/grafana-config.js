// == Configuration
// config.js is where you will find the core Grafana configuration. This file contains parameter that
// must be set before Grafana is run for the first time.

define(['settings'], function(Settings) {


  return new Settings({
    elasticsearch: "https://10.0.163.173/elasticsearch",
  datasources: {
    'sensu': {
      type: 'influxdb 0.9.0',
//      url: "http://%INFLUXDB_HOST%:%INFLUXDB_PORT%/db/sensu",
      url: "https://10.0.163.173/influxdb/",
      username: 'sensu',
      password: '%INFLUXDB_SENSU_PASSWD%'
    },
    'grafana': {
      type: 'influxdb 0.9.0',
      url: "http://%INFLUXDB_HOST%:%INFLUXDB_PORT%/db/grafana",
      username: 'grafana',
      password: '%INFLUXDB_GRAFANA_PASSWD%',
      grafanaDB: true
    }
  },

  /* Global configuration options
  * ========================================================
  */

  // specify the limit for dashboard search results
  search: {
    max_results: 100
  },

  // default home dashboard
  default_route: '/dashboard/file/default.json',

  // set to false to disable unsaved changes warning
  unsaved_changes_warning: true,

  // set the default timespan for the playlist feature
  // Example: "1m", "1h"
  playlist_timespan: "1m",

  // If you want to specify password before saving, please specify it below
  // The purpose of this password is not security, but to stop some users from accidentally changing dashboards
  admin: {
    password: ''
  },

  // Change window title prefix from 'Grafana - <dashboard title>'
  window_title_prefix: 'SENSU DOCKER - ',

  // Add your own custom panels
  plugins: {
    // list of plugin panels
    panels: [],
    // requirejs modules in plugins folder that should be loaded
    // for example custom datasources
    dependencies: [],
  }

  });
});
