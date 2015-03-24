{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set data = cfg.data %}

{{cfg.name}}-configs:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: "{{cfg.name}}-end-configs"
{{cfg.name}}-end-configs:
  mc_proxy.hook: []

{% for configs in data.get('configs', []) %}
{% for i, idata in configs.items() %}
config-{{i}}:
  file.managed:
    - source: "salt://makina-projects/{{cfg.name}}/files/{{idata.get('template', i)}}"
    - name: "{{idata.get('target', '{0}/{1}'.format(cfg.project_root, i))}}"
    - template: jinja
    - mode: {{idata.get('mode', '750')}}
    - user: {{idata.get('user', cfg.user)}}
    - group: {{idata.get('group', cfg.group)}}
    - watch:
      - mc_proxy: "{{cfg.name}}-configs"
    - watch_in:
      - mc_proxy: "{{cfg.name}}-end-configs"
    - defaults:
        cfg: "{{cfg.name}}"
{% endfor %}
{% endfor %}
