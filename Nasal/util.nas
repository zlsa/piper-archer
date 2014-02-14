
# Generic utility functions

var true=1;
var false=0;

var trange=func(il,i,ih,ol,oh) {
    i=(i-il)/(ih-il);
    return((i*(oh-ol))+ol);
};

var clamp=func(il,i,ih) {
    if(il > ih) {
	var temp=il;
	il=ih;
	ih=temp;
    }
    if(i < il) {
	i=il;
    } else if(i > ih) {
	i=ih;
    }
    return(i);
}

var crange=func(il,i,ih,ol,oh) {
    i=trange(il,i,ih,ol,oh);
    i=clamp(ol,i,oh);
    return(i);
}

