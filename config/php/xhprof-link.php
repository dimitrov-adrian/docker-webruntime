<?php

/**
 * @file
 * Simple script that enables XHProfRuns for current request if $_GET['xhprof'] is set,
 * and adds a link on bottom right to current data.
 *
 * Example:
 *
 * // somefile.php
 * include 'xhprof-link.php'
 *
 * localhost/somefile.php?xhprof=1234
 */

if (isset($_GET['xhprof'])) {
    if (function_exists('tideways_xhprof_enable')) {
        tideways_xhprof_enable();
    } else if (function_exists('tideways_enable')) {
        tideways_enable();
    } else if (function_exists('xhprof_enable')) {
        xhprof_enable();
    } else {
        user_error('Tideways/XHProf is not available.');
        return;
    }

    register_shutdown_function(function () {
        require_once '/usr/local/share/xhprof_lib/utils/xhprof_lib.php';
        require_once '/usr/local/share/xhprof_lib/utils/xhprof_runs.php';

        if (function_exists('tideways_xhprof_disable')) {
            $profilerData = tideways_xhprof_disable();
        } else if (function_exists('tideways_disable')) {
            $profilerData = tideways_disable();
        } else if (function_exists('xhprof_disable')) {
            $profilerData = xhprof_disable();
        }

        $appNamespace = $_GET['xhprof'] ? $_GET['xhprof'] : 'default';
        $xhprofRuns = new XHProfRuns_Default();
        $runId = $xhprofRuns->save_run($profilerData, $appNamespace);

        echo "
        <a  target='_blank'
            href='/.xhprof?run={$runId}&amp;source={$appNamespace}'
            style='position:fixed;bottom:0;right:0;background:#ccc;color:#111;text-shadow:1px 1px 0 #eee;padding:4px 6px;font:normal 12px sans-serif;z-index:9999999999;'
            >
            XHProf Output
        </a>";
    });
}
