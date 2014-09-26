package main

type EmoterCB interface {
	Cb(e * Emoter)
}

type BaseCB struct {}

func (cb BaseCB) Cb(e * Emoter) {
	// do nothing
}

type Emoter struct {
	Current string 
	HappyCB EmoterCB
	SadCB EmoterCB
	AngryCB EmoterCB
	BoredCB EmoterCB
}

func MakeEmoter() Emoter {
	e := Emoter{"happy",BaseCB{},BaseCB{},BaseCB{},BaseCB{}}
	return e
}

func (e *Emoter) Happy() {
	e.Current = "happy"
	e.HappyCB.Cb(e)
}
func (e *Emoter) Sad() {
	e.Current = "sad"
	e.SadCB.Cb(e)
}
func (e *Emoter) Angry() {
	e.Current = "angry"
	e.AngryCB.Cb(e)
}

func (e *Emoter) Bored() {
	e.Current = "bored"
	e.BoredCB.Cb(e)
}
func (e *Emoter) SetAll(cb EmoterCB) {
	e.BoredCB = cb
	e.SadCB = cb
	e.AngryCB = cb
	e.HappyCB = cb
}
