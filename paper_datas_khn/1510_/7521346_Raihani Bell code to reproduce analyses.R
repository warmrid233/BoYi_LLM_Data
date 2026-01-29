
library(MuMIn)
library(arm)
library(foreign)
library(MASS)
library(ordinal)



################################################################
combined analysis
################################################################
data<-read.csv("combined.csv", header=T)
names(data)

quantile(data$Paranoia)
para_fac<-ifelse(data$Paranoia<=35,1,
ifelse(data$Paranoia<=59,2,
ifelse(data$Paranoia<=160,3,)))
para_fac
para_f<-factor(para_fac, ordered=T);para_f

earn<-ifelse(data$earnmore<=20,1,
ifelse(data$earnmore<=40,2,
ifelse(data$earnmore<=60,3,
ifelse(data$earnmore<=80,4,
ifelse(data$earnmore<=100,5,)))))
earn_r<-factor(earn, ordered=T);earn_r

harm<-ifelse(data$harmme<=20,1,
ifelse(data$harmme <=40,2,
ifelse(data$harmme <=60,3,
ifelse(data$harmme <=80,4,
ifelse(data$harmme <=100,5,)))))
harm_r<-factor(harm, ordered=T);harm_r



Gen<-ifelse(data$Gender=="Male",1,0);Gen

#standardize continuous input variables
sdAge<-sd(data$Age)
meanAge<-mean(data$Age)
zAge<-(data$Age-meanAge)/(sdAge+sdAge)

sdPar<-sd(data$Paranoia)
meanPar<-mean(data$Paranoia)
zPara<-(data$Paranoia-meanPar)/(sdPar+sdPar)

#center binayr input variables
cGen<-(Gen-mean(Gen))
cFair<-data$fair_bin-mean(data$fair_bin)
cFrame<-data$frame_bin-mean(data$frame_bin)
cRole<-data$role_bin-mean(data$role_bin)

################################################################
earn more model COMBINED
################################################################

global.model<clm(earn_r~cGen
						+zAge+
						zPara+
						cFrame+
						cFair+
						cFrame:cFair+ 
						zPara:cFrame+ 
						zPara:cFair+ 
						cRole+
						cRole:zPara
						+cRole:cFair
						+cRole:cFair:zPara
						+zPara:cFrame:cFair, na.action=na.fail, data=data)

model.set<-dredge(global.model, REML=FALSE)
top.models<-get.models(model.set, subset=delta<2)
a<-model.avg(top.models, adjusted=FALSE, revised.var=TRUE)
summary(a)
confint(a, full=T)
convergence(global.model)

################################################################
predict interactions from this model
################################################################

################################################################
		fair x frame interaction
################################################################

aggregate(data$earnmore,list(data$fairness=="fair", data$frame=="give"),mean)
aggregate(data$earnmore,list(data$fairness=="fair", data$frame=="give"),sd)
aggregate(data$earnmore,list(data$fairness=="fair", data$frame=="give"),length)

par(font=1,font.lab=6,font.axis=6,font.main=6,font.sub=6,mai=c(0.5,0.6,0.3,0.1),mgp=c(1.5,0.5,0), mar=c(4.1, 4.1, 4.1, 8.1),
xpd=TRUE)
fp<-c(37.8,94.4,63.7,94.3)   
receiver<-matrix(fp,nrow=2)   
iqfp1<-c(1.27,0.59,1.18,0.53)   ; iqfp11<-matrix(iqfp1, nrow=2)
iqfp2<-c(1.27,0.59,1.18,0.53) ; iqfp22<-matrix(iqfp2, nrow=2)
pr.names<-c("Give frame", "Take frame")
fprplot<-barplot(height=receiver, names.arg=pr.names, beside=T,  
ylab="Inferred Dictator Motivated by Self Interest", ylim=c(0,105))
arrows(fprplot, receiver-iqfp11 , fprplot, receiver+iqfp22, length = 0.05,angle = 90,code = 3 )
legend(x=1,y=110, legend=c("Fair","Unfair"), fill=c("grey25","grey75"))

################################################################
		fair x paranoia interaction
################################################################
aggregate(data$earnmore,list(data$fairness=="fair", para_f=="3"),length)
aggregate(data$earnmore,list(data$fairness=="fair", data$frame=="give"),sd)
aggregate(data$earnmore,list(data$fairness=="fair", data$frame=="give"),length)

par(font=1,font.lab=6,font.axis=6,font.main=6,font.sub=6,mai=c(0.5,0.6,0.3,0.1),mgp=c(1.5,0.5,0), mar=c(4.1, 4.1, 4.1, 8.1),
xpd=TRUE)
fp<-c(51.2,95.3,48.1,94.7,54.9,92.6)   
receiver<-matrix(fp,nrow=2)   
iqfp1<-c(1.77,0.78,1.37,0.51,1.89,0.89)   ; iqfp11<-matrix(iqfp1, nrow=2)
iqfp2<-c(1.77,0.78,1.37,0.51,1.89,0.89) ; iqfp22<-matrix(iqfp2, nrow=2)
pr.names<-c("Low paranoia", "Medium paranoia" ,"High paranoia")
fprplot<-barplot(height=receiver, names.arg=pr.names, beside=T,  
ylab="Inferred Dictator Motivated by Self Interest", ylim=c(0,105))
arrows(fprplot, receiver-iqfp11 , fprplot, receiver+iqfp22, length = 0.05,angle = 90,code = 3 )
legend(x=1,y=110, legend=c("Fair","Unfair"), fill=c("grey25","grey75"))

################################################################
		COMBINED cause harm model
################################################################

global.model<-clm(harm_r~
						cGen
						+zAge
						+zPara
						+cFrame
						+cFair+
						+cFrame:cFair
						+zPara:cFrame
						+zPara:cFair
						+cRole
						+cRole:zPara
						+cRole:cFair
						+cRole:cFair:zPara
						+zPara:cFrame:cFair, na.action=na.fail, data=data)

						
model.set<-dredge(global.model, REML=FALSE)
top.models<-get.models(model.set, subset=delta<2)
a<-model.avg(top.models, adjusted=FALSE, revised.var=TRUE)
summary(a)
confint(a, full=T)

################################################################
		frame x paranoia interaction
################################################################
aggregate(data$harmme,list(data$frame=="give", para_f=="3"),length)

par(font=1,font.lab=6,font.axis=6,font.main=6,font.sub=6,mai=c(0.5,0.6,0.3,0.1),mgp=c(1.5,0.5,0), mar=c(4.1, 4.1, 4.1, 8.1),
xpd=TRUE)
fp<-c(11.7,22.7,13.7,22.7,26.2,31)   
receiver<-matrix(fp,nrow=2)   
iqfp1<-c(1.27,1.57,1.01,1.18,1.85,1.79)   ; iqfp11<-matrix(iqfp1, nrow=2)
iqfp2<-c(1.27,1.57,1.01,1.18,1.85,1.79) ; iqfp22<-matrix(iqfp2, nrow=2)
pr.names<-c("Low paranoia", "Medium paranoia" ,"High paranoia")
fprplot<-barplot(height=receiver, names.arg=pr.names, beside=T,  
ylab="Inferred Dictator Wanted to Cause Harm", ylim=c(0,55))
arrows(fprplot, receiver-iqfp11 , fprplot, receiver+iqfp22, length = 0.05,angle = 90,code = 3 )
legend(x=1,y=55, legend=c("Give frame","Take frame"), fill=c("grey25","grey75"))


################################################################
Plot Paranoia x Inference (both) for 2nd party and 3rd party roles
################################################################
para_more<-ifelse(data$Paranoia<=35,1,
ifelse(data$Paranoia<=60,2,
ifelse(data$Paranoia<=85,3,
ifelse(data$Paranoia<=110,4,
ifelse(data$Paranoia<=160,5,
)))))
para_more


aggregate(data$harmme,list(para_more=="5",data$role=="bystander"),sd)



para<-c(1,2,3,4,5)
rec.earn<-c(73.1,69.5,76,72.6,77.9)   
obs.earn<-c(73.6,73.4,72.4,71.8,72.8)
rec.earn.sem<-c(1.7,1.44,2.47,3.46,5.7)   
obs.earn.sem<-c(1.95,1.37,2.58,3.19,5.63)

rec.harm<-c(15.9,18.8,28.6,34.9,38.9)
obs.harm<-c(19.9,17.3,22.3,31,33.7)
rec.harm.sem<-c(1.33,1.15,2.59,3.58,7.21)
obs.harm.sem<-c(1.68,1.04,2.03,3.21,6.19)


par(mfrow=c(1,2),font=1,font.lab=6,font.axis=6,font.main=6,font.sub=6,mai=c(1,0.1,0.1,0.1),mgp=c(1.5,0.5,0), mar=c(3,3,4,1.5),
xpd=TRUE)

p<-plot(x=para, y=rec.harm, xlab="Paranoia" ,
ylab="Inferred Harmful Intentions", ylim=c(0,100))
arrows(para,rec.harm-rec.harm.sem , para, rec.harm+rec.harm.sem, length = 0.05,angle = 90,code = 3 )
points(x=para, y=obs.harm, col="red")
arrows(para,obs.harm-obs.harm.sem,para,obs.harm+obs.harm.sem, length=0.05, angle=90, code=3, col="red")
legend(x=1,y=117, legend=c("Receiver","Observer"), fill=c("black","red"))
mtext("(a)", adj=1)

p<-plot(x=para, y=rec.earn, xlab="Paranoia" ,
ylab="Inferred Self-Interest", ylim=c(0,100))
arrows(para,rec.earn-rec.earn.sem , para, rec.earn+rec.earn.sem, length = 0.05,angle = 90,code = 3 )
points(x=para, y=obs.earn, col="red")
arrows(para,obs.earn-obs.earn.sem,para,obs.earn+obs.earn.sem, length=0.05, angle=90, code=3, col="red")
mtext("(b)", adj=1)

