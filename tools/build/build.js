#!/usr/bin/env node
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { resolve: resolvePath } = require('path');
const { Task, exec } = require('./cbt');
const { regQuery } = require('./cbt/winreg');

// Change working directory to project root
process.chdir(resolvePath(__dirname, '../../'));

const taskTgui = new Task('tgui')
  .depends('tgui/.yarn/releases/*')
  .depends('tgui/yarn.lock')
  .depends('tgui/**/package.json')
  .depends('tgui/packages/**/*.js')
  .depends('tgui/packages/**/*.jsx')
  .provides('tgui/public/*.bundle.*')
  .provides('tgui/public/*.chunk.*')
  .build(async () => {
    if (process.platform === 'win32') {
      await exec('powershell.exe',
        '-NoLogo', '-ExecutionPolicy', 'Bypass',
        '-File', 'tgui/bin/tgui.ps1');
    }
    else {
      await exec('tgui/bin/tgui');
    }
  });

const taskDm = new Task('dm')
  .depends('code/**')
  .depends('goon/**')
  .depends('html/**')
  .depends('interface/**')
  .depends('tgui/public/tgui.html')
  .depends('tgui/public/*.bundle.*')
  .depends('tgui/public/*.chunk.*')
  .depends('tgstation.dme')
  .provides('tgstation.dmb')
  .provides('tgstation.rsc')
  .build(async () => {
    let compiler = 'dm';
    // Let's do some registry queries on Windows, because dm is not in PATH.
    if (process.platform === 'win32') {
      const installPath = (
        await regQuery(
          'HKLM\\Software\\Dantom\\BYOND',
          'installpath')
        || await regQuery(
          'HKLM\\SOFTWARE\\WOW6432Node\\Dantom\\BYOND',
          'installpath')
      );
      if (installPath) {
        compiler = resolvePath(installPath, 'bin/dm.exe');
      }
    }
    await exec(compiler, 'tgstation.dme');
  });

const runTasks = async () => {
  await taskTgui.run();
  await taskDm.run();
  console.log(' => Done');
  process.exit();
};

runTasks();
