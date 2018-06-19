# multithread-causality


Causality toolbox for systems observed through many parallel experiments



Details of each program and usage example is available by typing in the command window: help [function-name]

--------------------------------------------------

*When to use Multithread Causality?

When you are investigating the dynamics of a phenomena you may: (i) have a very long time-series of the observations of this phenomena, or (ii) have lots of small observations taken independently. The original Causality Toolbox was developed for the first case. The Multithread Causality tool addresses the second. Furthermore, the Multithread Causality is backward compatible, i.e., it can also be used for one single (long) observation of the cause/effect variables.

*What do the results mean?

The outcomes are the following information-theoretical values: Causal Mutual Information, Mutual Information, Transfer Entropy and Directionality Index (equivalent to a Net Transfer Entropy). Mathematical details can be seen in the references provided below.

Additionally, the Pointwise Information Measures, i.e. the contribution that each region of the phase-space gives to the information-theoretical values, is provided. This permits identifying, e.g., if a specific interval of values is responsible for the causation between the variables.

The values express the global information-theoretical values for the universe of observations provided.

*What is the confidence margin?

The confidence margin is a reference given by artificial [0,1] uncorrelated uniform pseudo-random distributions with the same size of the inputs. In principle all the information-theoretical values should yield zero in this case, but it doesn't happen in practice due to the limited size of the input and numerical errors in computation. The confidence margins are the largest obtained results from the method (after several runs) when these uncorrelated pseudo-random distributions are adopted as inputs. Only when the values are significantly above the confidence margins the hypothesis can be validated; otherwise there is at most an indication of potential links. 

--------------------------------------------------

(C) Dr Arthur Valencio[1,2]', Dr Norma Valencio[1,3]'' and Dr Murilo S. Baptista[1]

[1] Institute for Complex Systems and Mathematical Biology (ICSMB), University of Aberdeen

[2] Research, Innovation and Dissemination Center for Neuromathematics (RIDC NeuroMat)

[3] Department of Environmental Sciences, Federal University of Sao Carlos (UFSCar)

'Support: CNPq [206246/2014-5] and FAPESP [2018/09900-8], Brazil

''Support: FAPESP [17/17224-0] and CNPq [310976/2017-0], Brazil

This package is available as is, without any warranty. Use it at your own risk.

---------------------------------------------------
Version update: 18 June 2018

---------------------------------------------------

If useful, please cite:

(1) Arthur Valencio. An information-theoretical approach to identify seismic precursors and earthquake-causing variables. PhD thesis, University of Aberdeen, 2018. Available at: http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer

(2) Arthur Valencio, Norma Valencio and Murilo S. Baptista. Multithread causality: causality toolbox for systems observed through many short parallel experiments. Open source codes for Matlab. 2018. Available at: https://github.com/artvalencio/multithread-causality/

--------------------------------------------------

Bibtex entries:

@phdthesis{Valencio2018, author={Arthur Valencio}, title={An information-theoretical approach to identify seismic precursors and earthquake-causing variables}, school={University of Aberdeen}, year={2018},address={Aberdeen (UK)},note= {Available at: \url{http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer}.}}

@misc{cami, author={Valencio, Arthur and Valencio, Norma and Baptista, Murilo da Silva}, title={Pointwise Information: displaying the topology of causality from the time-series}, note={Open source codes for Matlab. Available at \url{https://github.com/artvalencio/multithread-causality/}.}, year={2018} }
