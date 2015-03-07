{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set php = salt['mc_php.settings']() %}
{% set data = cfg.data %}

{% if data.url %}
{{cfg.name}}-download:
{% if data.url_type == 'git' %}
  mc_git.latest:
    - rev: "{{data.rev}}"
    - name: "{{data.url}}"
    - target: "{{cfg.data_root}}/www"
    - user: "{{cfg.user}}"
{% else %}
  archive.extracted:
    - source: "{{data.url}}"
    - source_hash: "{{data.url_hash}}"
    - name: "{{cfg.data_root}}/www"
    - archive_format: "{{data.url_archive_format}}"
    - tar_options: "{{data.url_tar_opts}}"
    - user: "{{cfg.user}}"
    - group: "{{cfg.group}}"
    - onlyif: test ! -e "{{cfg.data_root}}/www/index.php"
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
    - mode: {{data.get(mode, '750')}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - mc_proxy: "{{cfg.name}}-configs"
    - defaults:
        cfg: "{{cfg.name}}"
{% endfor %}
