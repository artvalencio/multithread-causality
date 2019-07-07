# multithread-causality


Causality toolbox for systems observed through many parallel experiments



Details of each program and usage example is available by typing in the command window: help [function-name]

--------------------------------------------------

*When to use Multithread Causality?

When you are investigating the dynamics of a phenomena you may: (i) have a very long time-series of the observations of this phenomena, or (ii) have lots of small observations taken independently. The original Causality Toolbox was developed for the first case. The Multithread Causality tool addresses the second. Furthermore, the Multithread Causality is backward compatible, i.e., it can also be used for one single (long) observation of the cause/effect variables.

*What "Serial" Multithread CaMI is supposed to mean?

Oftentimes it is simply faster to perform the computation using serial scheme (i.e. running on one CPU core) instead of parallel (running on all available cores). In our case it is just a matter of using "for" instead of "parfor". Also, it is the way-to-go to Matlab users without the parallel computing toolbox. However, we remain with the principle of computing each small observation individually.

*How to interpret my results?

The outcomes are the following information-theoretical values: Causal Mutual Information, Mutual Information, Transfer Entropy and Directionality Index (equivalent to a Net Transfer Entropy). Mathematical details can be seen in the references provided below.

The values express the global information-theoretical values for the universe of observations provided.

*What about confidence margins?

The confidence margin is a reference of what you would get by chance instead of an actual observation of a physical phenomenon, so you can understand it as an error bar. You could get it by running the functions with two artificial [0,1] uncorrelated uniform pseudo-random distributions with the same size of the inputs, or, better, by shuffling the input data. In principle all the information-theoretical values should yield (close to) zero in this case, but it may not happen in practice due to the limited size of the input and numerical roundoff errors in computation. The confidence margins to be adopted are the largest obtained results after applying the functions over and over again. A given hypothesis can only be validated if the obtained values for the original input are significantly above the confidence margins. 

--------------------------------------------------

(C) Dr Arthur Valencio[1,2]', Dr Norma Valencio[3]'' and Dr Murilo S. Baptista[1]

[1] Institute for Complex Systems and Mathematical Biology (ICSMB), University of Aberdeen

[2] Research, Innovation and Dissemination Center for Neuromathematics (RIDC NeuroMat)

[3] Department of Environmental Sciences, Federal University of Sao Carlos (UFSCar)

'Support: CNPq [206246/2014-5] and FAPESP [2018/09900-8], Brazil

''Support: FAPESP [17/17224-0] and CNPq [310976/2017-0], Brazil

This package is available as is, without any warranty. Use it at your own risk.

---------------------------------------------------
Original: 19 June 2018

Version update: 07 July 2019

---------------------------------------------------

If useful, please cite:

(1) Arthur Valencio. An information-theoretical approach to identify seismic precursors and earthquake-causing variables. PhD thesis, University of Aberdeen, 2018. Available at: http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer

(2) Arthur Valencio, Norma Valencio and Murilo S. Baptista. Multithread causality: causality toolbox for systems observed through many short parallel experiments. Open source codes for Matlab. 2018. Available at: https://github.com/artvalencio/multithread-causality/

--------------------------------------------------

Bibtex entries:

@phdthesis{Valencio2018, author={Arthur Valencio}, title={An information-theoretical approach to identify seismic precursors and earthquake-causing variables}, school={University of Aberdeen}, year={2018},address={Aberdeen (UK)},note= {Available at: \url{http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer}.}}

@misc{cami, author={Valencio, Arthur and Valencio, Norma and Baptista, Murilo da Silva}, title={Pointwise Information: displaying the topology of causality from the time-series}, note={Open source codes for Matlab. Available at \url{https://github.com/artvalencio/multithread-causality/}.}, year={2018} }
