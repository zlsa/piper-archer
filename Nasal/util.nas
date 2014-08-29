
# Generic utility functions

var true=1;
var false=0;

var show = func(what) {print(what,"\n");}

var trange=func(il,i,ih,ol,oh) {
    return((((i-il)/(ih-il))*(oh-ol))+ol);
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
};

var crange=func(il,i,ih,ol,oh) {
    return(clamp(ol,trange(il,i,ih,ol,oh),oh));
};

var max=func(a, b) {
    if(a > b) return a;
    else      return b;
};
