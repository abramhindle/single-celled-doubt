s.boot;
s.scope;

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


SynthDef(\bbb, {
	|b,x=0,y=0,xvel=0,yvel=0,out=0,accel=100,amp=0.5|
	Out.ar(out,
		amp * Mix.ar(
			BufRd.ar(1, b, LFSaw.ar((x/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar((y/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
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
//~bbb.free;
//-10.0.abs

~listener = {|msg, time, addr, recvPort| 
	~twin.set(\x, msg[1]);
	~twin.set(\y, msg[2]);
	~twin.set(\xvel, msg[4]);
	~twin.set(\yvel, msg[5]);

	~happy.set(\amp, 0.5);
	~happy.set(\x, msg[1]);
	~happy.set(\y, msg[2]);
	~happy.set(\accel, msg[3]);
	~happy.set(\xvel, msg[4]);
	~happy.set(\yvel, msg[5]);

	"harsh".postln;
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

	~happy.set(\amp, 1.0);
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


	msg.postln
};



~collisionf = ~clistener;
~locatorf = ~listener;


~ldc = {|msg, time, addr, recvPort| 
	~collisionf.(msg,time,addr,recvPort)
};

~ldl = {|msg, time, addr, recvPort| 
	~locatorf.(msg,time,addr,recvPort)
};

~collision = OSCFunc.newMatching(~ldc, '/collision');
~locator = OSCFunc.newMatching(~ldl, '/locator');
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