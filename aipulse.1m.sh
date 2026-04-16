#!/bin/bash
# <bitbar.title>AIPulse</bitbar.title>
# <bitbar.version>v1.0.0</bitbar.version>
# <bitbar.author>Kami (@kamiwang777)</bitbar.author>
# <bitbar.author.github>kamiwang777</bitbar.author.github>
# <bitbar.desc>Menubar monitor for AI coding subscriptions (Claude Code, Codex). Shows 5h / weekly quota %.</bitbar.desc>
# <bitbar.image>https://raw.githubusercontent.com/kami/aipulse/main/screenshots/menubar.png</bitbar.image>
# <bitbar.dependencies>node,bash</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/kamiwang777/aipulse</bitbar.abouturl>
# <swiftbar.hideAbout>false</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideDisablePlugin>false</swiftbar.hideDisablePlugin>
# <swiftbar.environment>[AIPULSE_LANG=en, AIPULSE_THEME=cyberpunk]</swiftbar.environment>

# =====================================================================
# AIPulse — menubar monitor for AI coding subscriptions
# Author: Kami (@kamiwang777)  |  License: MIT  |  https://github.com/kamiwang777/aipulse
# =====================================================================

set -u
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# ---------- config loader ----------
CONFIG_FILE="${AIPULSE_CONFIG:-$HOME/.config/aipulse/config.sh}"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

: "${AIPULSE_LANG:=en}"                 # en | zh
: "${AIPULSE_THEME:=cyberpunk}"         # cyberpunk | mono
: "${AIPULSE_HIDE_CLAUDE:=0}"           # 1 to hide
: "${AIPULSE_HIDE_CODEX:=0}"            # 1 to hide
: "${AIPULSE_CC_5H_LIMIT:=max}"         # "max" = ccusage historical peak, or a number
: "${AIPULSE_CC_WEEK_LIMIT:=max}"       # "max" or a number
: "${AIPULSE_THRESH_WARN:=70}"          # % for yellow
: "${AIPULSE_THRESH_DANGER:=90}"        # % for red
: "${AIPULSE_THRESH_INFO:=50}"          # % for cyan (below = green)
: "${AIPULSE_SHOW_COST:=1}"             # show $ figures
: "${AIPULSE_NPX_BIN:=$(command -v npx || echo /opt/homebrew/bin/npx)}"

# ---------- i18n ----------
t() {
  local key=$1
  case "$AIPULSE_LANG" in
    zh)
      case "$key" in
        title)        echo "AI 编程额度监控" ;;
        claude)       echo "Claude Code" ;;
        codex)        echo "Codex" ;;
        fivehour)     echo "5 小时" ;;
        week)         echo "本周" ;;
        used)         echo "已用" ;;
        projected)    echo "预测窗口末" ;;
        burnrate)     echo "燃烧速率" ;;
        remaining)    echo "剩余" ;;
        models)       echo "模型" ;;
        thisweek)     echo "本周总计" ;;
        peakweek)     echo "历史峰值周" ;;
        plan)         echo "套餐" ;;
        resets)       echo "重置" ;;
        lastsession)  echo "最近会话" ;;
        context)      echo "上下文" ;;
        reset_now)    echo "已重置" ;;
        last)         echo "上次" ;;
        refresh)      echo "刷新" ;;
        footnote)     echo "Claude: ccusage 历史峰值基准 · Codex: 官方 rate_limits" ;;
        not_installed) echo "未安装" ;;
        no_data)      echo "无数据" ;;
        dep_missing)  echo "缺少依赖: node 或 npx 未安装" ;;
        docs)         echo "文档" ;;
        config)       echo "配置文件" ;;
      esac ;;
    *)
      case "$key" in
        title)        echo "AI Coding Quota" ;;
        claude)       echo "Claude Code" ;;
        codex)        echo "Codex" ;;
        fivehour)     echo "5h" ;;
        week)         echo "Week" ;;
        used)         echo "used" ;;
        projected)    echo "projected" ;;
        burnrate)     echo "Burn rate" ;;
        remaining)    echo "remaining" ;;
        models)       echo "Models" ;;
        thisweek)     echo "This week" ;;
        peakweek)     echo "peak week" ;;
        plan)         echo "plan" ;;
        resets)       echo "resets" ;;
        lastsession)  echo "Last session" ;;
        context)      echo "Context" ;;
        reset_now)    echo "reset" ;;
        last)         echo "last" ;;
        refresh)      echo "Refresh" ;;
        footnote)     echo "Claude: ccusage historical peak baseline · Codex: official rate_limits" ;;
        not_installed) echo "not installed" ;;
        no_data)      echo "no data" ;;
        dep_missing)  echo "missing dependency: node / npx not found" ;;
        docs)         echo "Docs" ;;
        config)       echo "Config file" ;;
      esac ;;
  esac
}

# ---------- theme ----------
theme_color() {
  local kind=$1
  case "$AIPULSE_THEME" in
    mono)
      case "$kind" in
        green) echo "#ffffff" ;; cyan) echo "#cccccc" ;;
        yellow) echo "#888888" ;; red) echo "#ff3333" ;;
        claude) echo "#ffffff" ;; codex) echo "#cccccc" ;;
        dim) echo "#555555" ;; subtitle) echo "#888888" ;;
      esac ;;
    *)  # cyberpunk
      case "$kind" in
        green) echo "#00ff88" ;; cyan) echo "#00ffff" ;;
        yellow) echo "#ffaa00" ;; red) echo "#ff3366" ;;
        claude) echo "#ff9966" ;; codex) echo "#00d488" ;;
        dim) echo "#555555" ;; subtitle) echo "#888888" ;;
      esac ;;
  esac
}

color_for_pct() {
  local pct=${1:-0}
  awk -v p="$pct" -v w="$AIPULSE_THRESH_WARN" -v d="$AIPULSE_THRESH_DANGER" -v i="$AIPULSE_THRESH_INFO" '
    BEGIN {
      if (p>=d) print "red";
      else if (p>=w) print "yellow";
      else if (p>=i) print "cyan";
      else print "green";
    }'
}

# ---------- dependency check ----------
if ! command -v node >/dev/null 2>&1 || ! command -v "$AIPULSE_NPX_BIN" >/dev/null 2>&1; then
  echo "AIPulse ⚠️ | color=$(theme_color red)"
  echo "---"
  echo "$(t dep_missing) | color=$(theme_color red)"
  echo "Install: brew install node | href=https://nodejs.org"
  exit 0
fi

# ---------- formatters ----------
fmt_tok() {
  local n=${1:-0}
  if [ "$n" -ge 1000000 ] 2>/dev/null; then awk "BEGIN{printf \"%.1fM\", $n/1000000}"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then awk "BEGIN{printf \"%.1fK\", $n/1000}"
  else echo "$n"; fi
}

fmt_time() {
  local m=${1:-0}
  if [ "$m" -ge 60 ] 2>/dev/null; then echo "$((m/60))h$((m%60))m"
  else echo "${m}m"; fi
}

fmt_countdown() {
  local reset=${1:-0}
  local now; now=$(date +%s)
  local diff=$((reset-now))
  if [ "$reset" -eq 0 ]; then echo "-"; return; fi
  if [ $diff -le 0 ]; then t reset_now; return; fi
  local h=$((diff/3600)) m=$(((diff%3600)/60))
  if [ $h -gt 24 ]; then echo "$((h/24))d$((h%24))h"
  elif [ $h -gt 0 ]; then echo "${h}h${m}m"
  else echo "${m}m"; fi
}

bar() {
  local pct=${1:-0}
  local filled empty s=""
  filled=$(awk "BEGIN{p=$pct;if(p>100)p=100;if(p<0)p=0;printf \"%d\", p/10}")
  empty=$((10-filled))
  [ $filled -gt 0 ] && for _ in $(seq 1 $filled); do s="${s}█"; done
  [ $empty -gt 0 ]  && for _ in $(seq 1 $empty);  do s="${s}░"; done
  echo "$s"
}

get() {
  echo "$1" | node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{try{const j=JSON.parse(d);console.log(j.$2!==undefined?j.$2:'');}catch(e){console.log('');}});" 2>/dev/null
}

# =====================================================================
# Claude Code provider (via ccusage)
# =====================================================================
fetch_claude() {
  [ "$AIPULSE_HIDE_CLAUDE" = "1" ] && { echo "{}"; return; }

  local blocks weekly
  blocks=$("$AIPULSE_NPX_BIN" -y ccusage@latest blocks --active --token-limit "$AIPULSE_CC_5H_LIMIT" --json 2>/dev/null)
  weekly=$("$AIPULSE_NPX_BIN" -y ccusage@latest weekly --json 2>/dev/null)

  [ -z "$blocks" ] && { echo "{}"; return; }

  node -e '
    const blocks=JSON.parse(process.argv[1]||"{}");
    const weekly=JSON.parse(process.argv[2]||"{}");
    const wkLimitArg=process.argv[3]||"max";

    const a=(blocks.blocks||[]).find(b=>b.isActive);
    let o={available:true};
    if(a){
      const lim=(a.tokenLimitStatus&&a.tokenLimitStatus.limit)||0;
      const proj=a.projection||{totalTokens:0,totalCost:0,remainingMinutes:0};
      o.h5_pct=lim?+(a.totalTokens/lim*100).toFixed(1):0;
      o.proj_pct=lim?+(proj.totalTokens/lim*100).toFixed(1):0;
      o.h5_cost=+a.costUSD.toFixed(2);
      o.h5_tok=a.totalTokens;
      o.h5_limit=lim;
      o.proj_cost=+(proj.totalCost||0).toFixed(2);
      o.remain=proj.remainingMinutes||0;
      o.burn=a.burnRate?Math.round(a.burnRate.tokensPerMinute):0;
      o.models=(a.models||[]).map(x=>x.replace("claude-","").replace(/-\d+.*/,"")).join(",")||"-";
    } else { o.h5_pct=0; o.h5_cost=0; o.h5_tok=0; o.h5_limit=0; o.proj_pct=0; o.proj_cost=0; o.remain=0; o.burn=0; o.models="-"; }

    const weeks=weekly.weekly||[];
    const now=new Date();
    const day=now.getDay();
    const diff=(day===0?-6:1-day);
    const monday=new Date(now); monday.setDate(now.getDate()+diff); monday.setHours(0,0,0,0);
    const mondayStr=monday.toISOString().slice(0,10);

    let curWeek=weeks.find(w=>w.week===mondayStr);
    if(!curWeek){
      const cand=weeks.filter(w=>new Date(w.week)<=now).sort((x,y)=>y.week.localeCompare(x.week));
      curWeek=cand[0];
    }
    o.wk_tok=curWeek?curWeek.totalTokens:0;
    o.wk_cost=+((curWeek?curWeek.totalCost:0)||0).toFixed(2);
    const wkLimit=(wkLimitArg==="max")?(weeks.length?Math.max(...weeks.map(w=>w.totalTokens)):0):+wkLimitArg;
    o.wk_limit=wkLimit;
    o.wk_pct=wkLimit?+(o.wk_tok/wkLimit*100).toFixed(1):0;

    console.log(JSON.stringify(o));
  ' "$blocks" "$weekly" "$AIPULSE_CC_WEEK_LIMIT" 2>/dev/null
}

# =====================================================================
# Codex provider (via session jsonl rate_limits)
# =====================================================================
fetch_codex() {
  [ "$AIPULSE_HIDE_CODEX" = "1" ] && { echo "{}"; return; }
  local dir="$HOME/.codex/sessions"
  [ ! -d "$dir" ] && { echo "{}"; return; }

  find "$dir" -name "rollout-*.jsonl" -type f 2>/dev/null | \
    xargs -I{} tail -n 200 "{}" 2>/dev/null | \
    grep '"rate_limits"' | \
    node -e '
      let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{
        const lines=d.trim().split("\n").filter(Boolean);
        let latest=null, ts=0;
        for(const ln of lines){
          try{
            const obj=JSON.parse(ln);
            const t=Date.parse(obj.timestamp||0);
            if(t>ts && obj.payload && obj.payload.rate_limits){ ts=t; latest=obj; }
          }catch(e){}
        }
        if(!latest){ console.log("{}"); return; }
        const p=latest.payload, rl=p.rate_limits||{}, info=p.info||{};
        const pri=rl.primary||{}, sec=rl.secondary||{};
        const tot=info.total_token_usage||{}, last=info.last_token_usage||{};
        const ctx=info.model_context_window||0;
        const lastCtx=last.total_tokens||0;
        console.log(JSON.stringify({
          available:true,
          h5_pct: pri.used_percent||0,
          h5_reset: pri.resets_at||0,
          wk_pct: sec.used_percent||0,
          wk_reset: sec.resets_at||0,
          plan: rl.plan_type||"-",
          total_tok: tot.total_tokens||0,
          in_tok: tot.input_tokens||0,
          cache_tok: tot.cached_input_tokens||0,
          out_tok: tot.output_tokens||0,
          reason_tok: tot.reasoning_output_tokens||0,
          ctx_win: ctx,
          last_ctx: lastCtx,
          ctx_pct: ctx?+(lastCtx/ctx*100).toFixed(1):0,
          ts: latest.timestamp
        }));
      });
    ' 2>/dev/null
}

CC=$(fetch_claude)
CX=$(fetch_codex)

CC_OK=$(get "$CC" available); CC_OK=${CC_OK:-}
CX_OK=$(get "$CX" available); CX_OK=${CX_OK:-}

# ---------- derive Claude values ----------
CC_H5=$(get "$CC" h5_pct);      CC_H5=${CC_H5:-0}
CC_WK=$(get "$CC" wk_pct);      CC_WK=${CC_WK:-0}
CC_COST=$(get "$CC" h5_cost);   CC_COST=${CC_COST:-0}
CC_TOK=$(get "$CC" h5_tok);     CC_TOK=${CC_TOK:-0}
CC_LIMIT=$(get "$CC" h5_limit); CC_LIMIT=${CC_LIMIT:-0}
CC_PROJ=$(get "$CC" proj_pct);  CC_PROJ=${CC_PROJ:-0}
CC_PROJC=$(get "$CC" proj_cost); CC_PROJC=${CC_PROJC:-0}
CC_REMAIN=$(get "$CC" remain);  CC_REMAIN=${CC_REMAIN:-0}
CC_BURN=$(get "$CC" burn);      CC_BURN=${CC_BURN:-0}
CC_MODELS=$(get "$CC" models);  CC_MODELS=${CC_MODELS:--}
CC_WKTOK=$(get "$CC" wk_tok);   CC_WKTOK=${CC_WKTOK:-0}
CC_WKMAX=$(get "$CC" wk_limit); CC_WKMAX=${CC_WKMAX:-0}
CC_WKCOST=$(get "$CC" wk_cost); CC_WKCOST=${CC_WKCOST:-0}

# ---------- derive Codex values ----------
CX_H5=$(get "$CX" h5_pct);       CX_H5=${CX_H5:-0}
CX_WK=$(get "$CX" wk_pct);       CX_WK=${CX_WK:-0}
CX_H5_RESET=$(get "$CX" h5_reset); CX_H5_RESET=${CX_H5_RESET:-0}
CX_WK_RESET=$(get "$CX" wk_reset); CX_WK_RESET=${CX_WK_RESET:-0}
CX_PLAN=$(get "$CX" plan);       CX_PLAN=${CX_PLAN:--}
CX_TOT=$(get "$CX" total_tok);   CX_TOT=${CX_TOT:-0}
CX_IN=$(get "$CX" in_tok);       CX_IN=${CX_IN:-0}
CX_CACHE=$(get "$CX" cache_tok); CX_CACHE=${CX_CACHE:-0}
CX_OUT=$(get "$CX" out_tok);     CX_OUT=${CX_OUT:-0}
CX_CTX_WIN=$(get "$CX" ctx_win); CX_CTX_WIN=${CX_CTX_WIN:-0}
CX_LAST_CTX=$(get "$CX" last_ctx); CX_LAST_CTX=${CX_LAST_CTX:-0}
CX_CTX_PCT=$(get "$CX" ctx_pct); CX_CTX_PCT=${CX_CTX_PCT:-0}
CX_TS=$(get "$CX" ts)

NOW=$(date +%s)
CX_H5_STALE=0; CX_WK_STALE=0
[ "${CX_H5_RESET:-0}" -gt 0 ] 2>/dev/null && [ "$NOW" -ge "$CX_H5_RESET" ] && CX_H5_STALE=1
[ "${CX_WK_RESET:-0}" -gt 0 ] 2>/dev/null && [ "$NOW" -ge "$CX_WK_RESET" ] && CX_WK_STALE=1
CX_H5_DISP=$CX_H5; CX_WK_DISP=$CX_WK
[ "$CX_H5_STALE" = "1" ] && CX_H5_DISP=0
[ "$CX_WK_STALE" = "1" ] && CX_WK_DISP=0

# =====================================================================
# Menubar line
# =====================================================================
parts=""
[ "$CC_OK" = "true" ] && parts+="✦ ${CC_H5}% · ${CC_WK}%"
[ "$CC_OK" = "true" ] && [ "$CX_OK" = "true" ] && parts+="   "
[ "$CX_OK" = "true" ] && parts+="🤖 ${CX_H5_DISP}% · ${CX_WK_DISP}%"
[ -z "$parts" ] && parts="AIPulse –"

MAX_PCT=$(awk "BEGIN{m=0;
  if($CC_H5>m)m=$CC_H5; if($CC_WK>m)m=$CC_WK;
  if($CX_H5_DISP>m)m=$CX_H5_DISP; if($CX_WK_DISP>m)m=$CX_WK_DISP;
  print m}")
echo "${parts} | color=$(theme_color $(color_for_pct $MAX_PCT))"

# =====================================================================
# Dropdown
# =====================================================================
echo "---"
echo "AIPulse by Kami (@kamiwang777) | size=14"

# ---- Claude section ----
if [ "$CC_OK" = "true" ]; then
  echo "---"
  echo "✦ $(t claude) | size=13 color=$(theme_color claude)"
  CC_H5_C=$(theme_color $(color_for_pct $CC_H5))
  CC_WK_C=$(theme_color $(color_for_pct $CC_WK))
  CC_PROJ_C=$(theme_color $(color_for_pct $CC_PROJ))
  echo "  $(t fivehour)    $(bar $CC_H5)  ${CC_H5}% | color=${CC_H5_C} font=Menlo"
  echo "  $(t week)  $(bar $CC_WK)  ${CC_WK}% | color=${CC_WK_C} font=Menlo"
  echo "  ─────── | color=$(theme_color dim)"
  if [ "$AIPULSE_SHOW_COST" = "1" ]; then
    echo "  $(t fivehour) $(t used): $(fmt_tok $CC_TOK) · $(fmt_tok $CC_LIMIT) · \$${CC_COST}"
    echo "  $(t projected): $(bar $CC_PROJ) ${CC_PROJ}% · \$${CC_PROJC} | color=${CC_PROJ_C}"
  else
    echo "  $(t fivehour) $(t used): $(fmt_tok $CC_TOK) · $(fmt_tok $CC_LIMIT)"
    echo "  $(t projected): $(bar $CC_PROJ) ${CC_PROJ}% | color=${CC_PROJ_C}"
  fi
  echo "  $(t burnrate): $(fmt_tok $CC_BURN)/min · $(t remaining) $(fmt_time $CC_REMAIN)"
  echo "  $(t models): ${CC_MODELS}"
  if [ "$AIPULSE_SHOW_COST" = "1" ]; then
    echo "  $(t thisweek): $(fmt_tok $CC_WKTOK) · \$${CC_WKCOST}  ($(t peakweek) $(fmt_tok $CC_WKMAX))"
  else
    echo "  $(t thisweek): $(fmt_tok $CC_WKTOK)  ($(t peakweek) $(fmt_tok $CC_WKMAX))"
  fi
elif [ "$AIPULSE_HIDE_CLAUDE" != "1" ]; then
  echo "---"
  echo "✦ $(t claude) · $(t no_data) | size=13 color=$(theme_color dim)"
fi

# ---- Codex section ----
if [ "$CX_OK" = "true" ]; then
  echo "---"
  echo "🤖 $(t codex) · ${CX_PLAN} $(t plan) | size=13 color=$(theme_color codex)"
  CX_H5_C=$(theme_color $(color_for_pct $CX_H5_DISP))
  CX_WK_C=$(theme_color $(color_for_pct $CX_WK_DISP))
  CX_H5_NOTE=""; [ "$CX_H5_STALE" = "1" ] && CX_H5_NOTE=" ⟳ $(t last) ${CX_H5}%"
  CX_WK_NOTE=""; [ "$CX_WK_STALE" = "1" ] && CX_WK_NOTE=" ⟳ $(t last) ${CX_WK}%"
  echo "  $(t fivehour)    $(bar $CX_H5_DISP)  ${CX_H5_DISP}%${CX_H5_NOTE} | color=${CX_H5_C} font=Menlo"
  echo "  $(t week)  $(bar $CX_WK_DISP)  ${CX_WK_DISP}%${CX_WK_NOTE} | color=${CX_WK_C} font=Menlo"
  echo "  ─────── | color=$(theme_color dim)"
  echo "  $(t fivehour) $(t resets): $(fmt_countdown $CX_H5_RESET) · $(t week) $(t resets): $(fmt_countdown $CX_WK_RESET)"
  echo "  $(t lastsession): $(fmt_tok $CX_TOT) (in $(fmt_tok $CX_IN) · cache $(fmt_tok $CX_CACHE) · out $(fmt_tok $CX_OUT))"
  echo "  $(t context): $(bar $CX_CTX_PCT) ${CX_CTX_PCT}% · $(fmt_tok $CX_LAST_CTX) · $(fmt_tok $CX_CTX_WIN)"
elif [ "$AIPULSE_HIDE_CODEX" != "1" ]; then
  echo "---"
  echo "🤖 $(t codex) · $(t not_installed) | size=13 color=$(theme_color dim)"
fi

# ---- footer ----
echo "---"
echo "ℹ️ $(t footnote) | size=10 color=$(theme_color dim)"
echo "🔄 $(t refresh) | refresh=true"
if [ "$CC_OK" = "true" ]; then
  echo "📊 ccusage blocks | bash='$AIPULSE_NPX_BIN' param1='-y' param2='ccusage@latest' param3='blocks' terminal=true"
  echo "📈 ccusage monthly | bash='$AIPULSE_NPX_BIN' param1='-y' param2='ccusage@latest' param3='monthly' terminal=true"
fi
[ "$CX_OK" = "true" ] && echo "📂 Codex sessions | bash='/usr/bin/open' param1='$HOME/.codex/sessions' terminal=false"
echo "⚙️ $(t config) | bash='/usr/bin/open' param1='-t' param2='$CONFIG_FILE' terminal=false"
echo "📘 $(t docs) | href=https://github.com/kamiwang777/aipulse"
