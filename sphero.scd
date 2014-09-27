s.boot;
s.scope;

/*
	ToDo:
	- [X] set emotion
*/


/* ideas:
	- axion buzzing and fitzing
	- collision bang
	- voice clips 
*/

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
s.sync;
~twin = Synth(\twin);
//~twin.free;
~happyb = Buffer.read(s,"goldberg-aria-da-capo.wav");
~harshb = Buffer.read(s,"peergynt5.wav");
~excitedb = Buffer.read(s,"peergynt2.wav");
~sadb = Buffer.read(s,"Gesualdo-O_vos_omnes-stretch.wav");

SynthDef(\bbb, {
	|b,x=0,y=0,xvel=0,yvel=0,out=0,accel=100,amp=0.5,rate=1.0|
	Out.ar(out,
		amp * Mix.ar(
			BufRd.ar(1, b, LFSaw.ar(rate*(x/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar(rate*(y/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar(((yvel*xvel)/(50*50.0))*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
		))

	//BufRd.ar(1, b, ((x+y+yvel)/1000.0).wrap(0,1.0)+LFSaw.ar((1.0/7.0)*BufDur.ir(b).reciprocal,iphase: x/1000.0).range(0, BufFrames.ir(b))))

		//BufRd.ar(1, b, x*y*LFSaw.ar(BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b)) ))
	    //BufRd.ar(1, b, x/1000 * BufFrames.ir(b)))
}).add();
s.sync;
~happy = Synth(\bbb,[\b,~happyb.bufnum]);
~harsh = Synth(\bbb,[\b,~harshb.bufnum]);
~excited = Synth(\bbb,[\b,~excitedb.bufnum]);
~sad = Synth(\bbb,[\b,~sadb.bufnum]);
~sad.set(\amp,1.0)

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

d = Dictionary.new;
d["sad"] = {
	"Sad emotion!".postln;
	~happy.set(\amp, 0.1);
	~harsh.set(\amp, 0.01);
	~excited.set(\amp,0.01);
	~twin.set(\amp, 0.01);
	~sad.set(\amp,10.0);
	~sad.set(\rate,20.0);
};
d["happy"] = {
	~happy.set(\amp, 4.0);
	~harsh.set(\amp, 0.0001);
	~excited.set(\amp,0.1);
	~twin.set(\amp, 0.01);
	~sad.set(\amp,0.001);
	~sad.set(\rate,2.0);
	~happy.rate(\rate,2.0);

};
d["angry"] = {
	~happy.set(\amp, 0.1);
	~harsh.set(\amp, 1.0);
	~excited.set(\amp,0.01);
	~twin.set(\amp, 0.01);
	~sad.set(\amp,0.001);
	~sad.set(\rate,1.0);

};
d["bored"] = {
	~happy.set(\amp, 0.21);
	~harsh.set(\amp, 0.01);
	~excited.set(\amp,0.01);
	~twin.set(\amp, 0.1);
	~sad.set(\amp,0.1);
	~sad.set(\rate,3.0);

};

~callemotion = { |emotion|
	emotion.postln;
	d[emotion.asString].postln;
	d[emotion.asString].();
};
~callemotion.("happy");
~emotionf = {
	|msg, time, addr, recvPort| 
	var key = msg[1];
	"111111111111111111111111".postln;
	~callemotion.(key);
	"0000000000000".postln;
};


~callemotion.("sad");



~ldc = {|msg, time, addr, recvPort| 
	~collisionf.(msg,time,addr,recvPort)
};

~ldl = {|msg, time, addr, recvPort| 
	~locatorf.(msg,time,addr,recvPort)
};

~lde = {|msg, time, addr, recvPort| 
	~emotionf.(msg,time,addr,recvPort)
};


~collision = OSCFunc.newMatching(~ldc, '/collision');
~locator = OSCFunc.newMatching(~ldl, '/locator');
~emotion = OSCFunc.newMatching(~lde, '/emotion');
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