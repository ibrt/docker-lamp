<table>
  <tr><td>OS Version:</td><td><?=exec('lsb_release -ds')?></td></tr>
  <tr><td>Apache Version:</td><td><?=apache_get_version()?></td></tr>
  <tr><td>PHP Version:</td><td><?=phpversion()?></td></tr>
  <tr><td>MySQL Version:</td><td><?=exec('mysqld --version')?></td></tr>
</table>