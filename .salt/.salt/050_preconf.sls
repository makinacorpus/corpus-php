{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set php = salt['mc_php.settings']() %}
{% set data = cfg.data %}

{% if data.app_url %}
{{cfg.name}}-download:
{% if data.app_url_type == 'git' %}
  mc_git.latest:
    - rev: "{{data.app_rev}}"
    - name: "{{data.app_url}}"
    - target: "{{data.app_root}}"
    - user: "{{cfg.user}}"
{% else %}
  archive.extracted:
    - source: "{{data.app_url}}"
    - source_hash: "{{data.app_url_hash}}"
    - name: "{{data.app_root}}"
    - archive_format: "{{data.app_url_archive_format}}"
    - tar_options: "{{data.app_url_tar_opts}}"
    - user: "{{cfg.user}}"
    - group: "{{cfg.group}}"
    - onlyif: "{{data.app_archive_test_exists}}" 
{% endif %}
    - watch_in:
      - mc_proxy: "{{cfg.name}}-configs" 
{% endif %}


{{cfg.name}}-config:
  mc_proxy.hook: []

{% for i, data in data.get('configs', []) %}
config-{{i}}:
  file.managed:
    - source: "salt://makina-projects/{{cfg.name}}/files/{{data.get('template', i)}}"
    - name: "{{data.get('target', '{0}/{1}'.format(cfg.project_root, i))}}"
    - template: jinja
    - mode: {{data.get('mode', '750')}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - mc_proxy: "{{cfg.name}}-configs"
    - defaults:
        cfg: "{{cfg.name}}"
{% endfor %}
