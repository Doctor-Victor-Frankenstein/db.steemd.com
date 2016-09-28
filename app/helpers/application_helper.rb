module ApplicationHelper
  def pretty_name(name)
    raise "invalid name: #{name}" unless /^[a-z0-9\.\-]+$/.match(name)
    active = @account && name == @account['name']

    link_to_unless(active, name, "/@#{name}", class: 'account'){|out| content_tag(:span, out, class: 'account')}
  end

  def pretty_num num, round = nil
    num    = round_auto(num, round) if round
    str    = num.to_s
    str    = ("%.10f" % num.to_f).sub(/0+$/, '') if str.include?('e')
    #raise "WTF! #{num} #{round} #{str.to_s}" if num == 10**-8
    str    = str.sub(/\.0$/, '').split('.')
    str[0] = str[0].reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    str.join('.')
  end

  def pretty_hash(hash)
    content_tag :pre, JSON.pretty_generate(hash).gsub("\n\n","\n").gsub(/\[\s+\]/, '[]').gsub(/\{\s+\}/, '{}').gsub('\"', '"').html_safe
  end

  def round_auto(n, pct, round_to_nearest = true)
    #raise "Invalid pct: #{pct}" unless pct >= 0 && pct <= 1
    raise "Invalid pct: #{pct}" unless pct >= -1 && pct <= 1
    return 0                    if n == 0
    return -round_auto(-n, pct) if n < 0
    return n.round(0)           if pct == 0 || (round_to_nearest && pct * n > 1)

    pct = pct.abs
    m = 0 - Math.log(pct * n, 10).round.to_i
    while (n - n.round(m-1)).abs.to_f / n < pct
      m -= 1
    end
    #m = m + 1 if m > 0 && m % 2 == 1
    n.round(m)
  end

  def tb(txt, a = 35); txt.length > a ? h(txt[0..a-1])+'&hellip;'.html_safe : h(txt); end
  def pretty_url(url)

    out = if /^https?:\/\/[^\s]+\.[a-z]{2,8}(\/|$)/.match(url)
      lbl = tb(url.sub(/^https?:\/\//, ''))
      url = url
    elsif /^[^\s]+\.[a-z]{2,8}$/.match(url)
      lbl = tb(url)
      url = "http://#{url}"
    else
      lbl = url.blank? ? '<missing>' : url
      url = nil
    end

    lbl = content_tag(:span, '', class: 'glyphicon glyphicon-link', style: url ? '' : 'color: red', title: lbl)
    url ? link_to(lbl, url) : lbl
  end

end
