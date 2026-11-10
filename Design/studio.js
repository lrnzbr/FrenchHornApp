/* Interaction study only: no microphone, sound generation, analytics or network requests. */
(() => {
  "use strict";
  const icons = {
    fingerings: '<circle cx="6" cy="8" r="3"/><circle cx="18" cy="8" r="3"/><circle cx="12" cy="17" r="3"/>',
    tuner: '<path d="M8 3v7a4 4 0 0 0 8 0V3M12 14v7M5 3h6M13 3h6"/>',
    metronome: '<path d="m8 3-5 18h18L16 3ZM7 17h10M12 17l6-11"/>',
    settings: '<path d="m10 3-1 3-3 1-3 3 2 2-1 3 3 3 3-1 2 2 3-2 3 1 2-3-1-3 2-2-3-3-3-1-1-3Z"/><circle cx="12" cy="12" r="3"/>',
    chevron: '<path d="m9 5 7 7-7 7"/>',
    left: '<path d="m15 5-7 7 7 7"/>',
    play: '<path d="m8 4 12 8-12 8Z" fill="currentColor" stroke="none"/>',
    stop: '<rect x="6" y="6" width="12" height="12" rx="2" fill="currentColor" stroke="none"/>',
    mic: '<rect x="9" y="2" width="6" height="13" rx="3"/><path d="M5 10v2a7 7 0 0 0 14 0v-2M12 19v3M9 22h6"/>',
    check: '<path d="m5 12 5 5L20 7"/>',
    close: '<path d="m6 6 12 12M18 6 6 18"/>',
    tap: '<path d="M9 14V5a2 2 0 0 1 4 0v8-4a2 2 0 0 1 4 0v4-2a2 2 0 0 1 4 0v6c0 3-2 5-5 5h-3c-2 0-4-1-5-3l-4-5a2 2 0 0 1 3-2Z"/>'
  };
  const icon = name => `<svg class="icon" viewBox="0 0 24 24" aria-hidden="true">${icons[name]}</svg>`;
  const escape = value => String(value).replace(/[&<>"']/g, char => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[char]));
  const sharpNames = ["C","C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"];
  const flatNames = ["C","D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"];
  const pitchName = (midi, flats = false) => (flats ? flatNames : sharpNames)[midi % 12] + (Math.floor(midi / 12) - 1);
  const frequency = midi => 440 * 2 ** ((midi - 69) / 12);
  const instruments = window.ADAGIO_INSTRUMENTS;
  if (!instruments?.length) throw new Error("Missing design fixtures. Run Design/scripts/export-fixtures.py.");
  let instrument = instruments.find(item => item.id === 2);
  const meters = {"2/4":2,"3/4":3,"4/4":4,"6/8":6};
  const scenarios = {tuned:"In tune",flat:"12 cents flat",sharp:"12 cents sharp",waiting:"Waiting for a note",permission:"Microphone required",denied:"Microphone access off",unavailable:"No microphone available",interrupted:"Audio interrupted",failed:"Microphone stopped",background:"Tuner paused"};
  const panels = [...document.querySelectorAll(".phone")].map((element, id) => ({element,id,tab:element.dataset.start,midi:72,flats:false,reference:false,mic:true,scenario:"tuned",bpm:96,meter:"4/4",accent:true,playing:false,beat:-1,phase:0,updated:0,taps:[],sheet:false}));

  function getNote(panel) {
    const spellings = instrument.notes.find(notes => notes[0].midi === panel.midi) || instrument.notes[0];
    return spellings[panel.flats && spellings.length > 1 ? 1 : 0];
  }
  function prettyNote(name, className = "note-display") {
    if (!/\d$/.test(name)) return `<span class="${className}">${escape(name)}</span>`;
    return `<span class="${className}">${escape(name.slice(0,-1))}<sub>${escape(name.slice(-1))}</sub></span>`;
  }
  function staff(note) {
    const step = note.octave * 7 + note.letter - 34; // B4 at staff center.
    const y = 86 - step * 6;
    const ledgers = [];
    for (let s = -6; s >= step; s -= 2) ledgers.push(86 - s * 6);
    for (let s = 6; s <= step; s += 2) ledgers.push(86 - s * 6);
    const top = Math.min(25, y - 15), bottom = Math.max(145, y + 15);
    return `<svg class="staff" viewBox="0 ${top} 320 ${bottom-top}" role="img" aria-label="Written ${escape(note.name)}, treble clef">
      ${[62,74,86,98,110].map(v=>`<path d="M38 ${v}H284" stroke="currentColor" stroke-width="1" opacity=".65"/>`).join("")}
      <text x="48" y="113" font-size="77" font-family="'Apple Symbols', 'Noto Music', serif" fill="currentColor">𝄞</text>
      ${ledgers.map(v=>`<path d="M171 ${v}h42" stroke="currentColor" stroke-width="1.4"/>`).join("")}
      ${note.accidental ? `<text x="155" y="${y+9}" font-size="30" fill="currentColor">${note.accidental < 0 ? "♭":"♯"}</text>`:""}
      <ellipse cx="192" cy="${y}" rx="12" ry="7" transform="rotate(-16 192 ${y})" fill="none" stroke="currentColor" stroke-width="3"/>
    </svg>`;
  }
  function heading(title) {
    const compact = instrument.id === 2 ? "Double horn · F / B♭" : instrument.name;
    return `<div class="tool-heading"><div><h2>${title}</h2><button class="instrument-link" data-action="settings" aria-label="Change instrument: ${escape(instrument.name)}">${escape(compact)}${icon("chevron")}</button></div>${title === "Tuner" ? '<span class="pill">Written pitch</span>' : ""}</div>`;
  }
  function fingeringRows(note) {
    if (!note.fingerings.length) return '<div class="empty-fingering">No fingering is listed for this note.</div>';
    return note.fingerings.map((values,index)=>{
      const positions = instrument.triggers === 2 ? [0,1,2,3,4] : instrument.triggers === 1 ? [0,2,3,4] : [2,3,4];
      const names = ["T","T2","1","2","3"];
      const side = [2,3].includes(instrument.id) ? values[1] ? "High F side" : values[0] ? "B♭ side" : "F side" : `Fingering ${index+1}`;
      const description = positions.map(i=>`${names[i]} ${values[i]?"pressed":"released"}`).join(", ");
      return `<div class="fingering-row"><div>${side}<small>${index === 0 ? "First listed" : `Alternative ${index}`}</small></div><div class="valves" role="img" aria-label="${description}">${positions.map(i=>`<span aria-hidden="true" class="valve ${i<2?"trigger":""} ${values[i]?"pressed":""}">${names[i]}</span>`).join("")}</div></div>`;
    }).join("");
  }
  function fingerings(panel) {
    const note = getNote(panel), sounding = note.midi + instrument.offset;
    const options = instrument.notes.filter(notes=>notes[0].octave === note.octave).map(notes=>{
      const item = notes[panel.flats && notes.length>1 ? 1:0];
      return `<option value="${item.midi}" ${item.midi===note.midi?"selected":""}>${escape(item.name)}</option>`;
    }).join("");
    const octaves = [...new Set(instrument.notes.map(n=>n[0].octave))];
    return `${heading("Fingerings")}<div class="fingering-scroll">
      <div class="note-panel"><div class="note-topline"><span>WRITTEN NOTE</span><strong>Horn in ${instrument.offset === -7 ? "F":"B♭"}</strong></div>${staff(note)}
      <div class="note-footer"><span>Sounds as<strong>${pitchName(sounding,panel.flats)} · ${frequency(sounding).toFixed(1)} Hz</strong></span><div class="note-nav"><button data-action="previous" aria-label="Previous chromatic note" ${note.midi === instrument.notes[0][0].midi?"disabled":""}>${icon("left")}</button>${prettyNote(note.name)}<button data-action="next" aria-label="Next chromatic note" ${note.midi === instrument.notes.at(-1)[0].midi?"disabled":""}>${icon("chevron")}</button></div></div></div>
      <div class="pitch-chooser"><label class="control-label">Note<select data-control="note" aria-label="Written note">${options}</select></label><label class="control-label">Octave<select data-control="octave" aria-label="Written octave">${octaves.map(o=>`<option ${o===note.octave?"selected":""}>${o}</option>`).join("")}</select></label></div>
      <div class="row"><div><h3 class="group-title">Fingerings</h3><span class="small-label fingering-key">● pressed · ○ released</span></div><button class="small-label secondary-button" data-action="spelling" aria-label="Switch to ${panel.flats?"sharp":"flat"} note names">${panel.flats?"♭ Flats":"♯ Sharps"}</button></div>
      <div class="surface">${fingeringRows(note)}</div>
      <p class="legend"><b></b> Pressed <b class="hollow"></b> Released ${instrument.triggers?"· T = thumb trigger":""}</p></div>
      <div class="fingering-transport"><button class="primary" data-action="reference">${icon(panel.reference?"stop":"play")}${panel.reference?"Stop reference":"Play reference"}</button><p class="caption">${panel.reference?`Previewing sounding ${pitchName(sounding,panel.flats)} · simulated playback`:`Hear sounding ${pitchName(sounding,panel.flats)} · A4 = 440 Hz`}</p></div>`;
  }
  function gauge(cents) {
    return `<div class="gauge" aria-hidden="true"><svg viewBox="0 0 300 100"><rect x="143" y="24" width="14" height="52" rx="7" fill="var(--success-muted)"/>
      ${Array.from({length:25},(_,i)=>{const x=6+i*12,major=i%6===0;return `<path d="M${x} ${major?38:44}V${major?66:60}" stroke="${i===12?"var(--success)":"var(--secondary)"}" stroke-width="${i===12?2:1}" opacity="${major?1:.55}"/>`;}).join("")}
      ${cents!==null?`<g class="needle" style="transform:translateX(${cents*2.75}px)"><path d="M150 23V78" stroke="var(--ink)" stroke-width="2"/><path d="m145 19 5 5 5-5" fill="var(--ink)"/></g>`:""}</svg></div><div class="gauge-labels"><span>−50 · Flat</span><span>0</span><span>Sharp · +50</span></div>`;
  }
  function tuner(panel) {
    const scenario = panel.mic ? panel.scenario : "background";
    const measuring = ["tuned","flat","sharp"].includes(scenario);
    const cents = !measuring ? null : scenario==="flat"?-12:scenario==="sharp"?12:.4;
    const written = 65 - instrument.offset; // Concert F4, transposed using the model fixture.
    const noteName = pitchName(written,panel.flats);
    const messages = {
      permission:["Allow microphone access","The tuner listens while this screen is open. Fingerings and metronome work without the microphone.","Enable microphone"],
      denied:["Microphone access is off","Allow microphone access in iPhone Settings, then return to the tuner.","Open Settings"],
      unavailable:["Connect a microphone","No usable audio input is available. Check your connection, then try again.","Try again"],
      interrupted:["Your audio was interrupted","When the call or other audio ends, resume the tuner.","Resume tuner"],
      failed:["The microphone stopped","Check your audio input and try again.","Try again"],
      background:["Tuner paused","Resume when you are ready to play.","Resume tuner"]
    };
    const message = messages[scenario];
    return `${heading("Tuner")}<div class="tuner-reading"><div class="reading-label">${measuring?"You're playing":"Written note"}</div>${prettyNote(measuring?noteName:"—", "hero-note")}<div class="sounding">${measuring?`Sounding <strong>F4</strong> · ${(frequency(65)*2**(cents/1200)).toFixed(1)} Hz`:"Play a steady, comfortable note"}</div>
      ${message ? `<div class="status-message" role="status"><strong>${message[0]}</strong><p>${message[1]}</p></div>`:`<p class="tuning-status ${scenario==="flat"||scenario==="sharp"?"attention":""}" role="status">${measuring?icon(scenario==="tuned"?"check":"tuner"):""}${scenarios[scenario]}</p><p class="cents">${cents===null?"— cents":`${cents>0?"+":""}${cents.toFixed(1)} cents`}</p>${gauge(cents)}`}
      </div><div class="tuner-meta surface"><div><span>Reference pitch</span><strong>A4 = 440 Hz</strong></div><div><span>Notation</span><strong>Horn in ${instrument.offset===-7?"F":"B♭"}</strong></div></div>
      <div class="input-status">${icon("mic")}${message?"Microphone inactive":"iPhone microphone · Listening"}</div>
      <button class="${message?"primary":"secondary-button full"}" data-action="${message?"recover":"pause"}">${message?message[2]:"Pause tuner"}</button>`;
  }
  function metronome(panel) {
    const word = panel.bpm<60?"Largo":panel.bpm<76?"Adagio":panel.bpm<108?"Andante":panel.bpm<120?"Moderato":panel.bpm<168?"Allegro":"Presto";
    return `${heading("Metronome")}<div class="tempo-display"><div class="tempo" data-value="tempo">${panel.bpm}</div><div class="unit" data-value="unit">${panel.meter==="6/8"?"Eighth":"Quarter"} notes per minute</div><div class="tempo-word" data-value="word">${word}</div></div>
      <div class="tempo-controls"><button class="stepper" data-action="slower" aria-label="Decrease tempo">−</button><input type="range" data-control="tempo" min="40" max="208" value="${panel.bpm}" aria-label="Tempo" aria-valuetext="${panel.bpm} beats per minute"><button class="stepper" data-action="faster" aria-label="Increase tempo">+</button></div><div class="range-labels"><span>40</span><span>208</span></div>
      <div class="beat-row" aria-hidden="true">${Array.from({length:meters[panel.meter]},(_,i)=>`<span class="beat-dot ${i===0&&panel.accent?"first":""} ${i===panel.beat?"current":""}"></span>`).join("")}</div>
      <div class="metro-settings surface"><div class="setting-row"><label for="meter-${panel.id}">Time signature</label><select id="meter-${panel.id}" data-control="meter">${Object.keys(meters).map(m=>`<option ${m===panel.meter?"selected":""}>${m}</option>`).join("")}</select></div><div class="setting-row"><label for="accent-${panel.id}">Accent first beat</label><input class="switch" id="accent-${panel.id}" type="checkbox" data-control="accent" ${panel.accent?"checked":""}></div></div>
      <button class="primary" data-action="metronome">${icon(panel.playing?"stop":"play")}${panel.playing?"Stop metronome":"Start metronome"}</button>
      <button class="tap-button" data-action="tap">${icon("tap")}Tap tempo</button><p class="caption">${panel.playing?"Visual beat preview · Audio is simulated":"Tempo changes apply while playing"}</p>`;
  }
  function settings(panel) {
    return `<section class="settings-sheet" role="dialog" aria-modal="true" aria-labelledby="settings-title-${panel.id}"><div class="sheet-handle"></div><div class="row"><span class="small-label">YOUR STUDIO</span><button class="icon-button" data-action="close-settings" aria-label="Close settings">${icon("close")}</button></div><h2 id="settings-title-${panel.id}">Settings</h2><label class="control-label">Your instrument<select data-control="instrument">${instruments.map(item=>`<option value="${item.id}" ${item.id===instrument.id?"selected":""}>${escape(item.name)}</option>`).join("")}</select></label><div class="notice">Instrument choice sets the fingering chart and written-pitch transposition together.</div><div class="setting-row"><span>Written pitch</span><span class="muted">${instrument.offset===-7?"Horn in F":"Horn in B♭"}</span></div><div class="setting-row"><span>Reference pitch</span><span class="muted">A4 = 440 Hz</span></div><div class="setting-row"><label for="dark-${panel.id}">Low light</label><input id="dark-${panel.id}" class="switch" type="checkbox" data-control="theme" ${document.body.classList.contains("dark")?"checked":""}></div><p class="sheet-brand">adagio studios</p><p class="sheet-copy">Tools that leave room for the music.</p><p class="sheet-copy">Design concept · French horn<br>App naming and identity are provisional.</p><button class="secondary-button full" data-action="close-settings">Done</button></section>`;
  }
  function render(panel, focusSelector) {
    const content = panel.tab==="fingerings"?fingerings(panel):panel.tab==="tuner"?tuner(panel):metronome(panel);
    panel.element.innerHTML = `<div class="statusbar" aria-hidden="true"><span>9:41</span><span class="right"><span class="signal">▂▄▆</span><span>◒</span><i class="battery"></i></span></div><header class="app-header"><div class="app-brand">adagio<small>FRENCH HORN</small></div><button class="icon-button" data-action="settings" aria-label="Open settings">${icon("settings")}</button></header><div class="tool-content" id="tool-${panel.id}" role="tabpanel" aria-label="${panel.tab}">${content}</div><nav class="tabbar" role="tablist" aria-label="Practice tools">${["fingerings","tuner","metronome"].map(tab=>`<button class="tab" role="tab" aria-controls="tool-${panel.id}" aria-selected="${tab===panel.tab}" tabindex="${tab===panel.tab?0:-1}" data-tab="${tab}">${icon(tab)}${tab[0].toUpperCase()+tab.slice(1)}</button>`).join("")}</nav><div class="home-indicator" aria-hidden="true"></div>${panel.sheet?settings(panel):""}`;
    if (panel.sheet) for (const child of panel.element.children) if (!child.classList.contains("settings-sheet")) child.inert = true;
    let previewControls=panel.element.parentElement.querySelector(".study-controls");
    if(!previewControls){previewControls=document.createElement("div");previewControls.className="study-controls";panel.element.after(previewControls);
      previewControls.addEventListener("change",event=>{panel.scenario=event.target.value;panel.mic=event.target.value!=="background";render(panel);previewControls.querySelector("select")?.focus({preventScroll:true});});}
    previewControls.innerHTML=panel.tab==="tuner"?`<label class="demo-state">Preview state<select aria-label="Simulated tuner state">${Object.entries(scenarios).map(([key,label])=>`<option value="${key}" ${key===(panel.mic?panel.scenario:"background")?"selected":""}>${label}</option>`).join("")}</select></label>`:"";
    if (focusSelector) panel.element.querySelector(focusSelector)?.focus({preventScroll:true});
  }
  function setTempo(panel, value) {
    panel.bpm = Math.max(40,Math.min(208,Math.round(value)));
    const tempo=panel.element.querySelector('[data-value="tempo"]');
    if(tempo)tempo.textContent=panel.bpm;
    const word=panel.element.querySelector('[data-value="word"]');
    if(word)word.textContent=panel.bpm<60?"Largo":panel.bpm<76?"Adagio":panel.bpm<108?"Andante":panel.bpm<120?"Moderato":panel.bpm<168?"Allegro":"Presto";
    const slider=panel.element.querySelector('[data-control="tempo"]');
    if(slider){slider.value=panel.bpm;slider.setAttribute("aria-valuetext",`${panel.bpm} beats per minute`);}
  }
  function toggleTheme(dark) {
    document.body.classList.toggle("dark",dark);
    document.getElementById("theme-toggle").setAttribute("aria-pressed",String(dark));
    for (const input of document.querySelectorAll('[data-control="theme"]')) input.checked=dark;
  }
  document.getElementById("theme-toggle").addEventListener("click",()=>toggleTheme(!document.body.classList.contains("dark")));
  panels.forEach(panel=>{
    render(panel);
    panel.element.addEventListener("click",event=>{
      const target=event.target.closest("button"); if(!target || target.disabled) return;
      if(target.dataset.tab){
        panel.tab=target.dataset.tab; panel.reference=false; panel.playing=false; panel.beat=-1;
        render(panel,`[data-tab="${panel.tab}"]`); return;
      }
      const action=target.dataset.action;
      const restore = `[data-action="${action}"]`;
      if(action==="settings"){panel.sheet=true;render(panel,'[data-action="close-settings"]');return;}
      if(action==="close-settings"){panel.sheet=false;render(panel,'[aria-label="Open settings"]');return;}
      if(action==="spelling")panel.flats=!panel.flats;
      if(action==="reference")panel.reference=!panel.reference;
      if(action==="previous"||action==="next"){
        const index=instrument.notes.findIndex(n=>n[0].midi===getNote(panel).midi);
        panel.midi=instrument.notes[index+(action==="next"?1:-1)][0].midi;panel.reference=false;
      }
      if(action==="pause"){panel.mic=false;panel.scenario="background";}
      if(action==="recover"){panel.mic=true;panel.scenario="tuned";}
      if(action==="slower"||action==="faster"){setTempo(panel,panel.bpm+(action==="faster"?1:-1));panel.element.querySelector(restore)?.focus();return;}
      if(action==="metronome"){panel.playing=!panel.playing;panel.phase=0;panel.updated=performance.now();panel.beat=panel.playing?0:-1;}
      if(action==="tap"){
        const now=performance.now();
        if(panel.taps.length && now-panel.taps.at(-1)>2500)panel.taps=[];
        panel.taps.push(now); panel.taps=panel.taps.slice(-5);
        if(panel.taps.length>1){const intervals=panel.taps.slice(1).map((v,i)=>v-panel.taps[i]);setTempo(panel,60000/(intervals.reduce((a,b)=>a+b)/intervals.length));}
      }
      render(panel,restore);
    });
    panel.element.addEventListener("change",event=>{
      const target=event.target,control=target.dataset.control;
      if(!control)return;
      if(control==="instrument"){
        instrument=instruments.find(item=>item.id===Number(target.value));
        for(const item of panels){item.reference=false;if(!instrument.notes.some(n=>n[0].midi===item.midi))item.midi=instrument.notes[0][0].midi;render(item,item===panel?'[data-control="instrument"]':null);}return;
      }
      if(control==="note"){panel.midi=Number(target.value);panel.reference=false;}
      if(control==="octave"){
        const desired=getNote(panel).midi%12+(Number(target.value)+1)*12;
        panel.midi=instrument.notes.some(n=>n[0].midi===desired)?desired:instrument.notes.find(n=>n[0].octave===Number(target.value))[0].midi;panel.reference=false;
      }
      if(control==="scenario"){panel.scenario=target.value;panel.mic=target.value!=="background";}
      if(control==="meter"){panel.meter=target.value;panel.beat=panel.playing?0:-1;panel.phase=0;panel.updated=performance.now();}
      if(control==="accent")panel.accent=target.checked;
      if(control==="theme"){toggleTheme(target.checked);return;}
      if(control==="tempo")return;
      render(panel,`[data-control="${control}"]`);
    });
    panel.element.addEventListener("input",event=>{if(event.target.dataset.control==="tempo")setTempo(panel,Number(event.target.value));});
    panel.element.addEventListener("keydown",event=>{
      if(event.key==="Escape" && panel.sheet){panel.sheet=false;render(panel,'[aria-label="Open settings"]');}
      if(event.key==="Tab" && panel.sheet){
        const items=[...panel.element.querySelectorAll('.settings-sheet button,.settings-sheet select,.settings-sheet input')];
        const first=items[0],last=items.at(-1);
        if(event.shiftKey&&document.activeElement===first){event.preventDefault();last.focus();}
        if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus();}
      }
      if(event.target.dataset.tab && ["ArrowRight","ArrowLeft"].includes(event.key)){
        event.preventDefault();const tabs=["fingerings","tuner","metronome"],index=tabs.indexOf(panel.tab);
        panel.tab=tabs[(index+(event.key==="ArrowRight"?1:2))%3];panel.playing=false;panel.reference=false;panel.beat=-1;
        render(panel,`[data-tab="${panel.tab}"]`);
      }
    });
  });
  function tick(now){
    for(const panel of panels){
      if(!panel.playing)continue;
      panel.phase+=(now-panel.updated)*panel.bpm/60000;panel.updated=now;
      const steps=Math.floor(panel.phase);
      if(steps){panel.phase-=steps;panel.beat=(panel.beat+steps)%meters[panel.meter];
        panel.element.querySelectorAll(".beat-dot").forEach((element,i)=>element.classList.toggle("current",i===panel.beat));}
    }
    requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
  document.addEventListener("visibilitychange",()=>{if(document.hidden)for(const panel of panels){panel.playing=false;panel.reference=false;panel.beat=-1;render(panel);}});
})();
