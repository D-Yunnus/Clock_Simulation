function Clock = Clock_Type(Node)

switch Node{2}

    case 'Caesium'
        Clock=[0,0,10^-22,10^-26,1,10^-30,10^5,0,0,0];
    case 'Rubidium'
        Clock=[0,0,10^-19,2.5*10^-23,1,2.25*10^-28,10^5,0,0,0];
    case 'Optical'
        Clock=[0,0,3.8*10^-23,5.625*10^-31,3,8.41*10^-34,2*10^5,0,0,0];
    case 'CSAC'
        Clock=[0,0,4*10^-16,10^-20,1,10^-24,10^3,0,0,0];
    case 'VCXO'
        Clock=[0,0,10^-13,2.5*10^-21,1,10^-24,10^3,0,0,0];

end
    

end