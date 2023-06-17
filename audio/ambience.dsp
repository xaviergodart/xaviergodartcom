import("stdfaust.lib");

steps = 16;
bpm = hslider("bpm",40,40,240,1);
sequencer = ba.beat(bpm) : ba.pulse_countup_loop(steps-1,1) : hbargraph("seq",0,steps-1);
euclidean_trig(offset, notes) = sequencer : +(offset) : *(notes) : %(steps) < notes : hbargraph("euclid",0,1);

randomtrig = os.impulse,(no.noise*0.5+1.0 : ba.sAndH(os.lf_imptrain(0.3)) > 0.8 : hbargraph("random",0,2)) :> _;
env = en.arfe(16, 16, 0.1, randomtrig == 1);
voice(freq, detune, mix) = os.osc(freq), os.square(freq*2)*0.3, os.triangle(freq+detune) :> _*mix;
voicelfo = os.lf_triangle(0.06);
voicelfo2 = os.lf_triangle(0.05);
drone = voice(130.81, 0, os.lf_squarewave(2)*voicelfo2), voice(196.00, 0, 1), voice(220.00, 0, 1), voice(261.63, 2, voicelfo), voice(233.08, 1, 1-voicelfo), voice(349.23, 1, voicelfo2)  :> ve.moog_vcf(0.4, 1100) : *(env);

note = 440+440*(no.noise*0.5+1.0 : ba.sAndH(os.lf_imptrain(1))) : qu.quantize(130.81, qu.dorian);
lead1 = os.sawtooth(note) : ve.moog_vcf(0.9, 1000) : _*(en.ar(0.01, 0.3, euclidean_trig(0, 3)==1));
lead2 = os.square(note) : ve.moog_vcf(0.9, 1000) : _*(en.ar(0.01, 0.3, euclidean_trig(0, 3)==0));

bass = os.osc(65.41*1.5), os.square(130.81) :> ve.moog_vcf(0.1, 700) : _*(en.ar(2, 16, sequencer==8));

process = drone*gain : +(bass*(gain/2)) <: +(lead1 : *(gain+0.2)),+(lead2 : *(gain+0.2)) : re.greyhole(dt, damp, size, early_diff, feedback, mod_depth, mod_freq) : (aa.hardclip : aa.cubic1),(aa.hardclip : aa.cubic1)
with {
    gain = hslider("Gain", 0.2, 0, 1, 0.1);
    dt = hslider("Delay Time",28,1,60,1);
    damp = hslider("Damping",0.7,0,1,0.1);
    size = hslider("Size",2.6,0.5,3,0.1);
    early_diff = hslider("Early diff",0.6,0,1,0.1);
    feedback = hslider("Feedback",0.4,0,1,0.1);
    mod_depth = hslider("Mod Depth",0.1,0,1,0.1);
    mod_freq = hslider("Mod Freq",1.7,0,10,0.1);
};
