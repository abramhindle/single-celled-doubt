s.boot;
s.scope;

~happyb = Buffer.read(s,"goldberg-aria-da-capo.wav");
~harshb = Buffer.read(s,"peergynt5.wav");
~excitedb = Buffer.read(s,"peergynt2.wav");
~sadb = Buffer.read(s,"Gesualdo-O_vos_omnes-stretch.wav");
~birdb = Buffer.read(s,"india-bird-reverb-clean.wav");


/*
	ToDo:
	- [X] set emotion
*/


/* ideas:
	- axion buzzing and fitzing
	- collision bang
	- voice clips 
*/

SynthDef(\reverb, {|out=0,in=0, mix=0.25, room=0.15, damp=0.5, amp=1.0|
	var signal = In.ar(in,2);
	ReplaceOut.ar(out,FreeVerb2.ar(signal[0],signal[1], mix, room, damp, amp))
}).add;




SynthDef(\twin, {
	|x=0,y=0,xvel=0,yvel=0,out=1,amp=0.01|
	var sig, base = (x+y+xvel+yvel).sqrt + 200;
	base = DelayL.ar(base, 1.0, 0.75, 0.5, base);
	sig = Mix.ar(SinOsc.ar(base, x, amp),
		SinOsc.ar(base*2, y, amp),
		SinOsc.ar(base*3, xvel, amp),
		SinOsc.ar(base*4, yvel, amp),
		SinOsc.ar(base*5, 0, amp/x),
		SinOsc.ar(base*6, 0, amp/y),
		SinOsc.ar(base*7, 0, amp/xvel),
		SinOsc.ar(base*8, 0, amp/yvel));
	Out.ar(out,
		DelayL.ar(sig, 0.9, 0.5, 0.5, sig))
}).add();

SynthDef(\bbb, {
	|b,x=0,y=0,xvel=0,yvel=0,out=0,accel=100,amp=0.5,rate=1.0|
	Out.ar(out,
		amp * Mix.ar(
			BufRd.ar(1, b, LFSaw.ar(rate*(x/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar(rate*(y/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar(((yvel*xvel)/(50*50.0))*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
		))
}).add();

//{ CombL.ar(Decay.ar(Dust.ar(1,0.5), 0.2, WhiteNoise.ar), 0.2, 0.2, 3) }.play;

//{ Decay.ar(Dust.ar(1,0.5), 0.2, WhiteNoise.ar) }.play;

SynthDef(\dhydro2, {
	|out=0,amp=1.0,freq=440.0,density=0.2,decaytime=1.0,attacktime=0.01|
	var nsize,n = (2..10);
	nsize = n.size;
	Out.ar(0,
		Decay2.ar(
			Dust.ar(density),
			attacktime,
			decaytime,
			amp * 
			(
				n.collect {arg i; 
					SinOsc.ar( (1.0 - (1.0/(i*i))) * freq )
				}).sum / nsize
		)
	)
}).add;


/////////////// WAIT //////////////


~dhydro = Synth(\dhydro2);
~dhydro.autogui;
~dhydro.set(\decaytime,0.3);

r = Synth(\reverb, addAction: \addToTail);
r.autogui;
//r = Synth(\reverb,[\in,8,\mix,1,\room,1,\damp,0.1])
//Synth(\singrain,[\out,0]);
r.set(\mix, 0.5);
r.set(\room, 0.5);
r.set(\damp, 0.9);

//r.set(\mix,0.0);
//r.set(\mix, 1.0);

//s.sync;
~twin = Synth(\twin);
~twin.autogui;
//~twin.free;

//s.sync;
~happy = Synth(\bbb,[\b,~happyb.bufnum]);
~harsh = Synth(\bbb,[\b,~harshb.bufnum]);
~excited = Synth(\bbb,[\b,~excitedb.bufnum]);
~sad = Synth(\bbb,[\b,~sadb.bufnum]);
~sad.set(\amp,0.1);
~bird = Synth(\bbb,[\b,~birdb.bufnum]);

~bird.autogui;
~happy.autogui;
~sad.autogui;

//~bbb.free;
//-10.0.abs

~listener = {|msg, time, addr, recvPort| 
	~twin.set(\x, msg[1]);
	~twin.set(\y, msg[2]);
	~twin.set(\xvel, msg[4]);
	~twin.set(\yvel, msg[5]);

	//~happy.set(\amp, 0.5);
	~happy.set(\x, msg[1]);
	~happy.set(\y, msg[2]);
	~happy.set(\accel, msg[3]);
	~happy.set(\xvel, msg[4]);
	~happy.set(\yvel, msg[5]);

	~sad.set(\x, msg[1]);
	~sad.set(\y, msg[2]);
	~sad.set(\accel, msg[3]);
	~sad.set(\xvel, msg[4]);
	~sad.set(\yvel, msg[5]);

	~excited.set(\x, msg[1]);
	~excited.set(\y, msg[2]);
	~excited.set(\accel, msg[3]);
	~excited.set(\xvel, msg[4]);
	~excited.set(\yvel, msg[5]);


	~bird.set(\x, msg[1]);
	~bird.set(\y, msg[2]);
	~bird.set(\accel, msg[3]);
	~bird.set(\xvel, msg[4]);
	~bird.set(\yvel, msg[5]);


	//~dhydro.set(\freq, (msg[5]+1)*(msg[4]+1));

	~harsh.set(\x, msg[1]);
	~harsh.set(\y, msg[2]);
	~harsh.set(\accel, msg[3]);
	~harsh.set(\xvel, msg[4]);
	~harsh.set(\yvel, msg[5]);

	msg.postln
};

~clistener = {|msg, time, addr, recvPort| 
	"collision listener".postln;
	~twin.set(\x, msg[1]);
	~twin.set(\y, msg[2]);
	~twin.set(\xvel, msg[4]);
	~twin.set(\yvel, msg[5]);

	//	~happy.set(\amp, 1.0);
	~happy.set(\x, msg[1]);
	~happy.set(\y, msg[2]);
	~happy.set(\accel, msg[3]);
	~happy.set(\xvel, msg[4]);
	~happy.set(\yvel, msg[5]);

	"excited".postln;
	~excited.set(\x, msg[1]);
	~excited.set(\y, msg[2]);
	~excited.set(\accel, msg[3]);
	~excited.set(\xvel, msg[4]);
	~excited.set(\yvel, msg[5]);

	~harsh.set(\x, msg[1]);
	~harsh.set(\y, msg[2]);
	~harsh.set(\accel, msg[3]);
	~harsh.set(\xvel, msg[4]);
	~harsh.set(\yvel, msg[5]);
	msg.postln
};


~myl = ();

~collisionf = ~clistener;
~locatorf = ~listener;

m = Dictionary.new;
m["square"] = {
	"Square!".postln;
	~sad.set(\rate,55.0);
	~sad.set(\amp,0.1);
	~happy.set(\rate,0.1);
	~dhydro.set(\freq,122);
	~bird.set(\amp,0.5);
	~bird.set(\rate,5.0);

};
m["star"] = {
	"star!".postln;
	~sad.set(\rate,3.0);
	~happy.set(\rate,55.0);
	~dhydro.set(\freq,3000);
	~bird.set(\amp,0.5);
	~bird.set(\rate,16.0);

};
m["pause"] = {
	"pause!".postln;
};
m["back"] = {
	"back!".postln;
	~dhydro.set(\freq,120);
	~dhydro.set(\density,1.0);
};
m["forward"] = {
	"forward!".postln;
	~dhydro.set(\freq,1200);
	~dhydro.set(\density,3.0);
};
m["left"] = {
	"left!".postln;
	~dhydro.set(\freq,500);

};
m["right"] = {
	"right!".postln;

	~dhydro.set(\freq,800);

};




d = Dictionary.new;
d["sad"] = {
	"Sad emotion!".postln;
	~happy.set(\amp, 0.1);
	~harsh.set(\amp, 0.001);
	~excited.set(\amp,0.001);
	~twin.set(\amp, 0.001);
	~sad.set(\amp,4.0);
	~sad.set(\rate,5.0);
	~excited.set(\rate, 100.0.rand);


	~dhydro.set(\freq, 10.0.rand + 420.0);
	~dhydro.set(\density, 0.5 + 3.0.rand);

};



d["happy"] = {
	~happy.set(\amp, 4.0);
	~harsh.set(\amp, 0.0001);
	~excited.set(\amp,0.1);
	~twin.set(\amp, 0.01);
	~sad.set(\amp,0.001);
	~sad.set(\rate,30.0);
	~happy.set(\rate,46.0);
	~dhydro.set(\freq, 1000.0.rand + 2333.0);
	~dhydro.set(\density, 0.5 + 10.0.rand);
	
};
d["angry"] = {
	~happy.set(\amp, 0.1);
	~harsh.set(\amp, 1.0);
	~harsh.set(\rate, 66.0);
	~excited.set(\amp,0.21);
	~excited.set(\rate,200.0.rand);
	~twin.set(\amp, 0.01);
	~sad.set(\amp,0.001);
	~sad.set(\rate,1.0);
	~dhydro.set(\freq, 10.0.rand + 80.0);
	~dhydro.set(\density, 0.5 + 6.0.rand);

};
d["bored"] = {
	~happy.set(\amp, 0.21);
	~harsh.set(\amp, 0.01);
	~excited.set(\amp,0.51);
	~twin.set(\amp, 0.03);
	~sad.set(\amp,0.1);
	~sad.set(\rate,3.0);
	~happy.set(\rate, 0.21);
	~harsh.set(\rate, 0.01);
	~excited.set(\rate,0.51);

	//{|freq=0.5,size=0.2| Out.ar(1,CombN.ar(Decay.ar(Dust.ar(freq,size), 0.01, WhiteNoise.ar), 0.2, 0.2, 3)) }.play;
	~dhydro.set(\freq, 10.0.rand + 220.0);
	~dhydro.set(\density, 0.2 + 1.0.rand);

};

~click = {|freq=0.4,size=0.2| Out.ar(1,CombN.ar(Decay.ar(Dust.ar(freq,size), 0.01, WhiteNoise.ar), 0.2, 0.2, 3)) }.play;
~click.autogui;
//~click.set(\freq,0.5);

~callemotion = { |emotion|
	emotion.postln;
	d[emotion.asString].postln;
	d[emotion.asString].();
};

~callmacro = { |macro|
	macro.postln;
	m[macro.asString].postln;
	m[macro.asString].();
};



~callemotion.("happy");
~emotionf = {
	|msg, time, addr, recvPort| 
	var key = msg[1];
	"111111111111111111111111".postln;
	~callemotion.(key);
	"0000000000000".postln;
};

~macrof = {
	|msg, time, addr, recvPort| 
	var key = msg[1];
	~callmacro.(key);
};



~callemotion.("happy");

/*

~callemotion.("sad");
~callemotion.("angry");
~callemotion.("bored");
~callmacro.("star");
~callmacro.("square");

*/

~ldc = {|msg, time, addr, recvPort| 
	~collisionf.(msg,time,addr,recvPort)
};

~ldl = {|msg, time, addr, recvPort| 
	~locatorf.(msg,time,addr,recvPort)
};

~lde = {|msg, time, addr, recvPort| 
	~emotionf.(msg,time,addr,recvPort)
};

~lmacro = {|msg, time, addr, recvPort| 
	~macrof.(msg,time,addr,recvPort)
};


~collision = OSCFunc.newMatching(~ldc, '/collision');
~locator = OSCFunc.newMatching(~ldl, '/locator');
~emotion = OSCFunc.newMatching(~lde, '/emotion');
~macro = OSCFunc.newMatching(~lmacro, '/macro');

//~emotion.free;
//~locator.free()
/*

OSCFunc.defaultDispatcher.unregister('/locator')
OSCFunc.defaultDispatcher.unregister('/collision')
OSCdef(\test).enable;
OSCdef(\collision, ~listener, '/collision', n);
OSCdef(\locator, ~listener, '/locator', n);

~collision
n = NetAddr("127.0.0.1", NetAddr.langPort); // loopback
OSCdef(\locator,
	{|msg, time, addr, recvPort| \matching.postln}, '/locator', n);
OSCdef(\locator,
	{|msg, time, addr, recvPort| msg.postln}, '/locator');
OSCdef(\collision,
	{|msg, time, addr, recvPort| "collision2".postln; msg.postln}, '/collision',n);


m = NetAddr("127.0.0.1", NetAddr.langPort); // loopback
m.sendMsg("/locator", "Hello App 1");
m.sendMsg("/collision", "Hello App 1");

*/