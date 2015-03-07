{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set data = cfg.data %}

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
