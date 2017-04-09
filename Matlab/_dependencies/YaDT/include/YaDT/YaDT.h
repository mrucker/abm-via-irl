/*
			 Salvatore Ruggieri (c), 2002-
*/

/** @file YaDT.h
  *
  * This is the header of the YaDT project.
  */ 

#if !defined(_YADT_H__INCLUDED_)
#define _YADT_H__INCLUDED_

#include <string>
#include <vector>
#include <stdexcept>
#include <ostream> /* standard istd::ostream and fstream */
#include <fstream> 
#include <iostream>

/** The Yet another Decision Tree builder namespace. */
namespace yadt
{
	/** YaDT version std::string. */
	const char *get_version();
	/** YaDT build number. */
	const int get_build();
	/** YaDT copyright std::string. */
	const char *get_copyright();


	/** Source of textual data. Data sources include: text files, gzipped text files,
		JDBC relational tables. The purpose of this class is to encapsulate information
		on accessing data. It is used in methods that need to read data. 
			@see table::load_meta_data()
			@see table::load_data()
			@see dtree::predict()
			@see dtree::evaluate()
	*/
	class datasource
	{
	public:
		/** Constructor.
		  * Takes a data source specification: "FILE\#filename\#c" specifies a file with
		  * name "filename" and where column separator is the char 'c'; 
		  * "FILE\#filename.gz\#c" specifies a gzipped file with name "filename.gz" and 
		  * where column separator is the char 'c';
		  * "JDBC\#driver\#url\#usr\#pwd\#sql" -- to be added.
		  *   @param %specs data source specification.
		  */
		datasource(const std::string &specs);
		/** Destructor. */
		~datasource();
	private:
	#ifndef DOXYGEN_SHOULD_SKIP_THIS
			friend class dtree;
			friend class table;
	#endif /* DOXYGEN_SHOULD_SKIP_THIS */
		std::string specifications;
	};

	// forward references
	class conf_matrix;
	class dtree;

	/** A relational table. A relational table is a collection of attributes
	  * (discrete, continuous), of a class and, possibly, of a weights column. 
	  */
	class table
	{
	public:
		/** Constructor.
		  *   @param name %table name.
		  */
		table(const std::string &name);
		/** Destructor. */
		~table();
		/** Copy constructor not defined. */
		table( const table& );
		/** Assignment constructor not defined. */
		const table& operator=( const table& );
		/** Load metadata from a datasource. */
		void load_meta_data(const datasource &ds)
				 throw(std::runtime_error);
		/** Return table name. */
		std::string get_name() const;

		/** Load a table from a datasource. 
		  *    @param ds data source
		  *    @param unknown the unknown token
		  */
		void load_data(const datasource &ds, const std::string &unknown = "?") 
			throw(std::runtime_error);
		/** Return number of columns in the table. */
		size_t get_no_columns() const;
		/** Return number of rows in the %table. */
		size_t get_no_rows() const;
		/** Return the weight of a given row in the %table. Returns default
		  * weight (1) if no weight column is in the table. */
		float get_weight(size_t pos) const;
		/** Return the class of a given row in the %table.  */
		std::string get_class(size_t pos) const;

		/** Binary output. Attention: binary input/output is not guarranteed
		  * to be consistent among different releases of this library!!
		  *   @param filename the input filename. */
		void toBinary(const std::string &filename) const; 
		/** Binary input. Attention: binary input/output is not guarranteed
		  * to be consistent among different releases of this library!!
		  *   @param filename the output filename. */
		static table* fromBinary(const std::string &filename); 

		/* utility methods */

		/** Set output log. Default value is NULL, i.e. no output.
		  *     @param new_log output log.
		  *     @return old output log.	  */
		std::ostream *set_log(std::ostream *new_log);
		/** Set output log verbosity of operations.
		  * Verbosity values are: 0 = none, 1 low, 2 normal, 3 high.
		  *     @param newverbosity new verbosity of output.
		  *     @return old verbosity of output. */
		size_t set_verbosity(size_t newverbosity);
		/** Return elapsed time for lastloading of table. In other words, this
		  * method returns the elapsed time of the last call to the 
		  * load_data() method. */
		double get_elapsed() const;
		/** XML output of data dictionary. PMML 2.0 complaint. */
		void toXML_data_dictionary(std::ostream &os = std::cout) const; 
		/** XML output of mining schema.  PMML 2.0 complaint. */
		void toXML_mining_schema(std::ostream &os = std::cout) const; 

		/** A subset of a table. The purpose of this class is to
		  * encapsulate information on accessing a subset of a table. 
		  * A subset can only be obtained
		  * as the return value of some computation.
		  * @see dtree::build()
		  * @see dtree::predict() 
		  * @see table::get_wsubset_all() 
		  */
		class subset
		{
		public:
			/** Constructor. */
			subset();
			/** Destructor. */
			~subset();
			/** Copy constructor not defined. */
			subset( const subset& );
			/** Assignment constructor not defined. */
			const subset& operator=( const subset& );
			/** Returns number of elements in the subset. */
			size_t size() const;
			/** Resize the subset. */
			void resize(size_t newsize);
			/** Reserve space in the subset. */
			void reserve(size_t size);
			/** Add a new element.
			  *	@param tablepos case position in the table
			  * @param weight case weight
			  */
			void push_back(size_t tablepos, float weight);
			/** Get an element in the subset.
			  *	@param subsetpos element position in the subset
			  * @return a pair with case position and weigth
			  */
			std::pair<size_t, float> get(size_t subsetpos);
			/** Set an element in the subset.
			  *	@param subsetpos element position in the subset
			  *	@param tablepos case position in the table
			  * @param weight case weight
			  */
			void set(size_t subsetpos, size_t tablepos, float weight);

		private:
	#ifndef DOXYGEN_SHOULD_SKIP_THIS
			friend class dtree;
			friend class table;
	#endif /* DOXYGEN_SHOULD_SKIP_THIS */
			/** Private constructor. */
			subset(void *actual);
			void *real;
		};

		/** Return new weighted subset for all table rows. Weights of cases (i.e., rows) in the
		  * returned subset are assigned accordingly to the weights column, if
		  * present or to the default value (1.0) otherwise. */
		subset* get_wsubset_all() const;
		/** Return new weighted subset for first n table rows. Weights of cases (i.e., rows) in the
		  * returned subset are assigned accordingly to the weights column, if
		  * present or to the default value (1.0) otherwise. */
		subset* get_wsubset_first_n(size_t n) const;
		/** Return new weighted subset for n randomly selected (no repetition) table rows. 
		  * Weights of cases (i.e., rows) in the
		  * returned w_sequence are assigned accordingly to the weights column, if
		  * present or to the default value (1.0) otherwise. */
		subset* get_wsubset_random(size_t n) const;
		/** Return new weighted subset as difference from a given one. 
		  * The returned subset consists of all tables rows not present in the passed
		  * subset. Weights of cases (i.e., rows) in the
		  * returned w_sequence are assigned accordingly to the weights column, if
		  * present or to the default value (1.0) otherwise. */
		subset* get_wsubset_difference(subset *subtable) const;

	private:
	#ifndef DOXYGEN_SHOULD_SKIP_THIS
		friend class conf_matrix;
		friend class dtree;
	#endif /* DOXYGEN_SHOULD_SKIP_THIS */
		/** Actual table class. */
		void *real;
	};

	/**
	  * Models a confusion matrix. A confusion matrix is a matrix n x n 
	  * of weight_type::type, where n is the number of distinct values of a class
	  * (including the "unknown" class value). 
	  * For a %conf_matrix object cm, cm.get_element(act, pred) represents the weighted sum of 
	  * cases of class with index act predicted as belonging to class of index pred.
	  * The "unknown" class value has index 0: cm.get_element(0, x) should be 0 since actual 
	  * classes should never be "unknown" (this may happen, however, if the actual
	  * class of cases in the test set did not appear in the training set); 
	  * cm.get_element(x, 0) should be 0 since predicted classes should never be "unknown".
	  * A confusion matrix can only be obtained
	  * as the return value of some computation.
	  * @see dtree::predict
	  */
	class conf_matrix 
	{
	public:
		/** Destructor. */
		~conf_matrix();
		/** Copy constructor not defined. */
		conf_matrix( const conf_matrix& );
		/** Assignment constructor not defined. */
		const conf_matrix& operator=( const conf_matrix& );
		/** Clone method. Return a newly allocated %conf_matrix that is a clone
		  * of the called object.
		  */
		conf_matrix* clone() const;
		/** Return degree of the matrix. The degree of a matrix n x n, is n. */
		size_t size() const;
		/** Return a cell of the matrix. */
		float get_element(size_t actual, size_t predicted) const;
		/** Return misclassification percentage of the confusion matrix.
		  * The misclassification percentage of a %conf_matrix object cm
		  * is sum(i != j, cm[i, j]).
		  */
		float mis_perc() const;
		/** Return total weights in the confusion matrix. More formally,
		  * for a %conf_matrix object cm, it is returned sum(true, cm[i, j]).
		  */
		float cases() const;
		/** Return elapsed time taken to build the confusion matrix. */
		double get_elapsed() const;
		/** Text output of the confusion matrix.
		  *     @param os output stream.
		  *     @param space indent space.
		  */
		void toTEXT(std::ostream& os = std::cout, size_t space = 0) const;
		/** XML output of the confusion matrix. */
		void toXML(std::ostream& os = std::cout) const;

	private:
	#ifndef DOXYGEN_SHOULD_SKIP_THIS
		friend class dtree;
	#endif /* DOXYGEN_SHOULD_SKIP_THIS */
		/** Private constructor. A confusion matrix can only be obtained
		  * as the return value of some computation.
		  * @see dtree::predict
		  */
		conf_matrix(table *maintable)
			throw(std::runtime_error);
		conf_matrix(const conf_matrix *cm)
			throw(std::runtime_error);
		/** Actual class. */
		void *real;
	};

	/**
	  * A decision tree. The class provides methods for building, simplifying,
	  * and evaluating a decision tree.
	  */
	class dtree 
	{
	public:
		/** Constructor. @param name decision tree name. */
		dtree(const std::string &name="my_decision_tree");
		/** Destructor. */
		~dtree();
		/** Copy constructor not defined. */
		dtree( const dtree& );
		/** Assignment constructor not defined. */
		const dtree& operator=( const dtree& );
		/** Return a clone of the called object. */
		dtree* clone() const;

		/** Return elapsed time (in secs) taken to build tree. */
		double get_elapsed() const;
		/** Return number of tree nodes. */
		size_t size() const;
		/** Return tree depth. */
		size_t depth() const;
		/** Return number of cases used in building the tree. */
		size_t training_n_rows() const;

		/** Pruning strategy options. */
		typedef enum {
			/** No pruning. */
			PRUNING_NO, 
			/** C4.5 pruning strategy. */
			PRUNING_C45, 
			/** YaDT pruning strategy. */
			PRUNING_DT
		} PruningStrategy;

		/** Split type of a splitting decision node. */
		typedef enum {
			/** Information gain split. */
			ST_GAIN,
			/** Information gain ratio split. */
			ST_GAIN_RATIO
		} SplitType;

		/** Other options. */
		typedef enum {
			/** When correcting by log(N-1)/|D|, compute |D| as absolute count. */
			SET_ABSOLUTE_CORRECTION,
			/** When correcting by log(N-1)/|D|, compute |D| as sum of weights. */
			SET_WEIGHTED_CORRECTION
		} Options;

		/** Set simplification strategy.
		  *   @param strategy new pruning strategy.
		  *   @return true if setting the new strategy succeeded. */
		bool set_pruning_strategy(PruningStrategy strategy);
		/** Set split strategy.
		  *   @param st new split strategy.
		  *   @return true if setting the new strategy succeeded. */
		bool set_split_type(SplitType st);
		/** Set other options.
		  *   @param opt other option.
		  *   @return true if setting the new strategy succeeded. */
		bool set_option(Options opt);
		/** Set mininum weight of cases in sons in order to further split a node
		  *  during tree building. Default value is 2.0. Any value must be > 0.
		  *   @param min_objects new minimum weight.
		  *   @return true if setting the new weight succeeded. */
		bool set_min_obj(float min_objects);
		/** Set confidence level in simplifying a decision tree. The new
		  * confidence level must be in the range [0,1].*/
		bool set_conf_level(float conf_level);

		/**  Build an pruned tree. The method builds a tree and simplifies it.
		  *    @param maintable a table containing the training set.
		  *    @param subtable the subset of maintable used as training set. 
		  *            NULL value denotes all the table as training set.
		  *    @param evaluate true if a confusion matrix must be also computed. The
		  *            resulting confusion matrix can be obtained by calling the
		  *            get_prediction() method.
		  *    @param ff_worker number of worker in multi-core execution
		  *    @see set_pruning_strategy(), set_split_type(), set_min_obj(), set_conf_level()
		  */
		void build(table* maintable, table::subset *subtable, bool evaluate = true, int ff_worker = 0)
			throw (std::runtime_error);
		/** Return confusion matrix over the training set. The method returns NULL if no
		  * tree was build or it was build by not requiring the computation of a confusion
		  * matrix. 
		  * @see build_unpruned(), build_pruned()
		  */
		conf_matrix* get_prediction();
		/** Test classes of unseen cases. The source rst::inpout::stream is required to 
		  * provide for each case all attributes in the same order as the columns
		  * of training set and then the actual class: no weights must be provided.
		  *    @param ds provider of unseen cases.
		  *    @return a confusion matrix comparing prediction against actual classes.
		  */
		conf_matrix* predict(const datasource &ds) const
			throw(std::runtime_error);
		/** Predict classes of unseen cases. The source rst::inpout::stream is required to 
		  * provide for each case all attributes in the same order as the columns
		  * of training set: no class or weights must be provided. Optionally, a 
		  * further attribute may be provided (tipically a key of the case) that is
		  * produced in output together with predicted class and confidence.
		  *    @param ds provider of unseen cases.
		  *    @param output output stream of predictions.
		  *    @param sep %column separator in output stream.
		  *	   @returns elapsed time.
		  */
		double evaluate(const datasource &ds, std::ostream &output, char sep = '\t') const
			throw(std::runtime_error);
		/** Predict class and confidence of an unseen case stored in a table of the same 
		  * format as training (except for the class attribute). Optionally, a case weight may be
		  * provided (which affects confidence of prediction).
		  *    @param cases a table containing the unseen cases.
		  *    @param pos the case position in the table.
		  *    @param weight case weight.
		  *    @return a pair with predicted class and confidence.
		  */
		std::pair<std::string, float> predict(table* cases, size_t pos, float weight = 1) const;
		/** Predict class and confidence of an unseen case. The attributes of the case are 
		  * provided as a vector of C std::strings in the same order as the columns
		  * of training set: no class must be provided. Optionally, a case weight may be
		  * provided (which affects confidence of prediction).
		  *    @param attributes vector of C std::string representing case attributes.
		  *    @param weight case weight.
		  *    @return a pair with predicted class and confidence.
		  */
		std::pair<std::string, float> predict(const std::vector<std::string> &attributes, float weight = 1) const;
		// predict all cases in a given table
		/** Test classes of unseen cases. The cases table is required to 
		  * provide for each case all attributes in the same order as the columns
		  * of training set and the actual class of cases. If a weights %column is
		  * prese: no weights must be provided.
		  *    @param cases a table containing the unseen cases.
		  *    @param subtable the subset of cases to test. 
		  *            NULL value denotes all the table.
		  *    @return a confusion matrix comparing prediction against actual classes.
		  */
		conf_matrix* predict(table* cases, table::subset *subtable) const
			throw(std::runtime_error);

		/** Textual output. */
		void toTEXT(std::ostream& os = std::cout) const;
		/** Dot output. */
		void toDOT(std::ostream& os = std::cout) const;
		/** XML output. PMML 2.0 complaint. */
		void toXML(std::ostream &os = std::cout, const conf_matrix *cmTest = NULL) const; 

		/** Binary output. 
		  *   @param filename the output filename. */
		void toBinary(const std::string &filename);
		/** Binary input. 
		  *   @param filename the input filename.
		  *   @returns a newly allocated decision tree. */
		static dtree *fromBinary(const std::string &filename);

	private:
		/** Actual decision tree. */
		void *real;
	};

} // namespace yadt

/*! \mainpage YaDT: Yet another Decision Tree builder

<center>
<b>Version 1.2.5 (October 2010)</b><br>
<em>(c) Salvatore Ruggieri, 2002-2010</em><br>
<a href="http://www.di.unipi.it/~ruggieri">http://www.di.unipi.it/~ruggieri</a>
</center>
<p>

The C4.5 decision tree induction algorithm [4] is a constant reference among 
classification models in data mining and machine learning. A previous work [3] 
introduces EC4.5, a patch to the original C4.5 implementation  that vastly 
improves over time efficiency (up to 5X over public datasets [6]).
Based on the achievements of [3] and on some further optimizations, a new 
implementation has been designed and implemented in standard C++ 
<em>from-scratch</em>. This new implementation, called YaDT [1], provides 
the following benefits:
<ul>
  <li> a structured object-oriented programming implementation,
  <li> portable code over Windows (Visual Studio) and Linux (gcc) as well as over 32 bit and 64 bit machines,
  <li> a documented C++ library of classes,
  <li> PMML [5] compliant XML output of trees,
  <li> compressed binary ouput/input of trees,
  <li> further tree construction features: case weightings, hould-out,
       simplified error-based pruning,
  <li> a \link cmdline command line \endlink tree builder and a \link gui Java GUI \endlink
</ul>
and still it improves over
<ul>
  <li>time efficiency wrt EC4.5 (up to 4X),
  <li>memory occupation wrt EC4.5 (up to 3X).
</ul>
YaDT has been recently [2] enhanced with parallelism over multi-core machines (as for now,
only for Linux) by exploiting the <a href="http://sourceforge.net/projects/mc-fastflow/">Fastflow</a> library. 
This allows for achieving up to 2.7X speedup over sequential YaDT on a typical quad-core desktop machine.
<p>
YaDT is distributed free for research and/or educational purposes. See \link licence licence \endlink.
<p>
<b>References</b><p>
[1] S. Ruggieri. <a href="http://www.di.unipi.it/~ruggieri/Papers/yadt.pdf">
<em>YaDT: Yet another Decision Tree builder</em></a>. 16th International Conference on
Tools with Artificial Intelligence (ICTAI 2004): 260-265. IEEE Press, November 2004.
<p>
[2] M. Aldinucci, S. Ruggieri, M. Torquati.
<a href="http://www.di.unipi.it/~ruggieri/Papers/pkdd2010.pdf"><em>Porting Decision Tree Algorithms
to Multicore using FastFlow</em></a>. 21th European Conference on Machine Learning and 14th
Principles and Practice of Knowledge Discovery in Databases (ECML-PKDD 2010), Part I: 7-23.
Vol. 6321 of LNCS, Springer, September 2010.
<p>
[3] S. Ruggieri. <a href="http://www.di.unipi.it/~ruggieri/Papers/ec45.pdf"><em> Efficient C4.5</em></a>.
IEEE Transactions on Knowledge and Data Engineering, 14(2):438-444, March-April 2002.
<p>
[4] J.R.Quinlan.
<em> C4.5: Programs for Machine Learning</em>, Morgan Kaufmann 1993
<p>
[5] Data Mining Group. <em> Predictive Model Markup Language (PMML), version 2.0</em>,
<a href="http://www.dmg.org">http://www.dmg.org</a>
<p>
[6] S. Hettich and S.D. Bay. <em> The UCI KDD Archive</em>,
Irvine, CA: University of California, Department of Information and Computer Science.
<a href="http://kdd.ics.uci.edu">http://kdd.ics.uci.edu</a>
<p>
 */

 /*! \page gui YaDT from a Java GUI
 The YaDT GUI provides a user-friendly graphical user interface (GUI) for
 building decision trees, allowing for saving/loading them in binary format 
 and for exporting them as <a href="http://www.dmg.org">PMML</a> complaint documents.
 <p>
 The GUI is written in Java, and it requires java 1.4 or higher JRE installed.
 <p>
 The YaDT GUI does not implement any decision tree or binary/XML feature.
 It simply translates user clicks to calls to the
 <a href="cmdline.html">dTcmd</a> command line interpreter.
 <p>
 The current version of the YaDT GUI is intended only as a demonstration of the
 features of the YaDT classes. Not all features, however, have a GUI counterpart.
 For instance, the <a href="cmdline.html">dTcmd</a> command line interpreters
 offers options for applying a decision tree to a scoring set, i.e. to predict
 the class of cases with unknown class.
 <p>
 <hr><p>
 The YaDT GUI allows for loading/saving decision trees in binary format and 
 for exporting them in XML. Also, the YaDT GUI provides a wizard for building 
 decision trees. The wizard  accepts the following options.
 <p><b>Input options in building decision trees</b>
 <p>
 Input data to dTcmd consists of (possibly gzipped) text files:
 <ul>
 <li> a table describing <a href="cmdline.html#metadata">metadata</a>,
 <li> a table containing <a href="cmdline.html#training">training</a> cases,
 <li> (optional) a table containing <a href="cmdline.html#test">test</a> cases, or
      a percentage of cases in the training table (the rest is used for building the tree).
 </ul>
 <p><b>Tree construction parameters</b>
 <p>
 The following parameters affect the tree construction algorithm:
 <ul>
 <li> minimum cases in child nodes in order to split a node,
 <li> pruning confidence level.
 </ul>
 <p>
*/


 /*! \page cmdline YaDT from command line
dTcmd is a command line program that exploits (some of) the features of YaDT C++ classes in order to
build decision trees. dTcmd takes a metadata table and a training table as inputs and it constructs
a decision tree. There are command line options to specify the minimum number of cases to split
a node and the confidence limits in pruning tree. Also, optional test table and scoring table
may be specified. Tables can be in comma separated text files, gzipped text files, or in internal
binary format. Built trees can be saved as <a href="http://www.dmg.org">PMML</a> complaint
XML documents, text files or in binary format.

Command line arguments:
<p>
<b>&gt; dTcmd32 &lt;input options&gt; &lt;tree options&gt; &lt;output options&gt;</b>

dTcmd64 is the 64 bit compiled version of dTcmd32. It runs 10-15\% faster than dTcmd32 both on Windows
and Linux.

<p>
Command line options:
<ul>
<li>
<a href="#input">input data options</a><br>
<li>
<a href="#tree">tree construction options</a><br>
<li>
<a href="#output">output options</a><br>
</ul>


<p>
<a name="input">
<hr>
<p><b>Input data options</b>
<p>
Input data options for dTcmd:
<ul>
<li> a table describing <a href="#metadata">metadata</a>
 (option <b>-fm &lt;file&gt;</b>)
<li> a table containing <a href="#training">training</a> cases
 (option <b>-fd &lt;file&gt;</b>)
<li> a <a href="#binary">binary</a> file previously saved by dTcmd containing both metadata
 and training tables (option <b>-bd &lt;file&gt;</b>)
<li> a table containing <a href="#test">test</a> cases
 (option <b>-ft &lt;file&gt;</b>)
<li> a table containing cases to <a href="#score">score</a>
 (option <b>-fs &lt;file&gt;</b>)
</ul>
The option <b>-f &lt;file&gt;</b> is a shorthand for <b>-fm &lt;file&gt;.names -fd &lt;file&gt;.data</b>

Tables are represented either:
<ul>
<li> as comma-separated <a href="#text">text files</a>,
<li> as <a href="#gztext">gzipped</a> comma-separated text files</a> for filenames ending with <b>.gz</b>.
</ul>
Mixture of text files and gzipped text files are possible (e.g.,metadata being in a (gzipped) text file
whilst training data being in a text file).
<p>
<a name="tree">
<hr>
<p><b>Tree construction options</b>
<p>
The following parameters affect the tree construction algorithm:
<ul>
<li> set minimum cases to split a node
(option <b>-m &lt;num&gt;</b> where <b>num</b> is greater than 1,default is 2)
<li> set pruning confidence level
(option <b>-c &lt;num&gt;</b> where <b>num</b> is in the range (0,1], default is 0.25)
<li> set pruning strategy exactly as C4.5
(option <b>-c4.5</b>, default not set)
<li> set no pruning strategy at all
(option <b>-np</b>)
<li> randomly split training data in the data for building the tree and data for testing it
(option <b>-h &lt;num&gt;</b> where <b>num</b> is the percentage (in the range [0,100])
of cases to be used for building the tree, default is 100)
<li> do not to build the tree from input data files, but load
it from a <a href="#btree">binary</a> file previously saved by dTcmd
(option <b>-bt &lt;file&gt;</b>)
</ul>
<p>
<a name="output">
<hr>
<p><b>Output options</b>
<p>
The following options affect the outputs of dTcmd:
<ul>
<li> output metadata and training table in <a href="#binary">binary</a> format to a file
 (option <b>-db &lt;file&gt;</b>): this has no effect if option <b>-bt</b> is used
<li> output tree in <a href="#xtree">XML format</a> to a file
 (option <b>-x &lt;file&gt;</b>)
or to standard output
 (option <b>-xstd</b>)
<li> output <a href="#scored">scored</a>  cases to a file
 (option <b>-s &lt;file&gt;</b>)
<li> output tree in binary format to a file
 (option <b>-tb &lt;file&gt;</b>)
<li> output <a href="#cm">confusion matrix</a>  and text format tree to a file
 (option <b>-t &lt;file&gt;</b>)
or to standard output
 (option <b>-tstd</b>)
<li> output <a href="#log">verbose log</a> to a file
 (option <b>-l &lt;file&gt;</b>)
or to standard output
 (option <b>-lstd</b>)
</ul>
Zero,one of more of these options can be specified.
<p>
<a name="text">
<hr>
<p>
<b>Text files</b>
<p>
Text files code tables in comma-separated format. To change separator to the
character <b>c</b>, use the option <b>-sep &lt;c&gt;</b>. For instance,
<b>-sep " "</b> switcesh to space separated columns. Also,the special string
<b>"?"</b> represent unknown/null values.

<p>
<a name="gztext">
<hr>
<p>
<b>Gzipped text files</b>
<p>
Gzipped text files are files with suffix .gz obtained by compressing text files with
<a href="http://www.gzip.org/">gzip</a>.
<p>
<a name="metadata">
<hr>
<p>
<b>Metadata table</b>
<p>
Metadata tables have three columns, which in order represents:
<ul>
<li> training column names,
<li> training column data types,which can be:
<ul>
<li> <b>null</b>,i.e.,no value (requires column type <b>ignore</b>)
<li> <b>string</b>,i.e.,any string delimited by column separator or end of line,
<li> <b>integer</b>,i.e.,any integer value,
<li> <b>float</b>,i.e.,any float value,
</ul>
<li> training column types,which can be
<ul>
<li> <b>ignore</b>,i.e.,do not use column in tree construnction,
<li> <b>discrete</b>,i.e.,column is used as a discrete attribute,(not compatible with <b>null</b> data type),
<li> <b>continuous</b>,i.e.,column is used as a continuous attribute (not compatible with <b>null</b> or <b>string</b> data type),
<li> <b>weights</b>,i.e.,column is used to weight cases
(not compatible with <b>null</b> or <b>string</b> data type,and at most one column can be of this type),
<li> or <b>class</b> i.e.,column contains class values (not compatible with <b>null</b> data type,and exactly one column of
this type must be present).
</ul>
</ul>
For instance,the file <b>golf.names</b>
<pre>
outlook,string,discrete
temperature,integer,continuous
humidity,integer,continuous
windy,string,discrete
toPlay,string,class
</pre>
describes training data consisting of the following columns:
<ul>
<li>outlook,which contains strings interpreted as discrete values
<li>temperature,which contains integers interpreted as continuous values
<li>humidity,which contains integers interpreted as continuous values
<li>windy,which contains strings interpreted as discrete values
<li>goodPlaying, which contains floats inpreted as weight values
<li>toPlay,which contains strings interpreted as class values
</ul>

<p>
<a name="training">
<hr>
<p>
<b>Trainig data table</b>
<p>
Training data tables have a number of columns according
to the metadata table. The order of columns must be consistent with the
order of metadata table rows. Unknown values are not admitted when the column type
is <b>weights</b> or <b>class</b>.
Here it is the <b>golf.data</b> training data file:
<pre>
sunny,85,85,false,1,Don't Play
sunny,80,90,true,1,Don't Play
overcast,83,78,false,1.5,Play
rain,70,96,false,0.8,Play
rain,68,80,false,2,Play
rain,65,70,true,1,Don't Play
overcast,64,65,true,2.5,Play
sunny,72,95,false,1,Don't Play
sunny,69,70,false,1,Play
rain,75,80,false,1.5,Play
sunny,75,70,true,3,Play
overcast,72,90,true,1.5,Play
overcast,81,75,false,1,Play
rain,71,80,true,1,Don't Play
</pre>

<p>
<a name="binary">
<hr>
<p>
<b>Binary data table</b>
<p>
dTcmd may save and load a binary file containing a binary representation of
a metadata table and a training table (see options, <b>-bd &lt;file&gt;</b> and
<b>-db &lt;file&gt;</b>). Binary input/output is faster and binary file size is
much less than text file size. However, <b>binary files are not guarranteed to be readable
from future/past version of YaDT!</b>

<p>
<a name="btree">
<hr>
<p>
<b>Binary tree</b>
<p>
dTcmd may save and load a binary file containing a binary representation of
a decision tree (see options, <b>-bt &lt;file&gt;</b> and
<b>-tb &lt;file&gt;</b>). <b>Binary files are not guarranteed to be readable
from future/past version of YaDT!</b>

<p>
<a name="xtree">
<hr>
<p>
<b>XML tree</b>
<p>
dTcmd may save to a file or to standard output a <a href="http://www.dmg.org">PMML</a> complaint
XML representation of the built tree (see options, <b>-x &lt;file&gt;</b> and
<b>-xstd</b>).

<p>
<a name="cm">
<hr>
<p>
<b>Confusion matrix and text trees</b>
<p>
dTcmd may save to a file or to standard output a text representation of the built tree
and of confusion matrix over training and test data (see options, <b>-t &lt;file&gt;</b> and
<b>-tstd</b>).

<p>
<a name="log">
<hr>
<p>
<b>Verbose log</b>
<p>
dTcmd may save to a file or to standard output a verbose log of computation in progress
(see options, <b>-l &lt;file&gt;</b> and
<b>-lstd</b>).

<p>
<a name="test">
<hr>
<p>
<b>Test data table</b>
<p>
Test data table has exactly the same format of training data table.

<p>
<a name="score">
<hr>
<p>
<b>Score data table</b>
<p>
Score data table has the same format of training data table with the following exceptions:
<ul>
<li> the <b>weights</b> column is not present,
<li> the <b>class</b> column is not present,
<li> all other columns maintan the same relative order,
<li> an additional column, which we call the <b>key column</b>,
may optionally be present as the last column of the score table.
</ul>
An example score file for the golf example is the following:
<pre>
overcast,80,75,false,1
rain,90,75,true,2
sunny,98,82,false,3
sunny,80,75,true,4
overcast,90,75,false,5
rain,78,82,false,6
</pre>

<p>
<a name="scored">
<hr>
<p>
<b>Scored data table</b>
<p>
Scoring a score data with a tree yields a scored data table in output as a text file containing
in the same order of score data table:
<ul>
<li> if present,the <b>key column</b> column in the score data table,
<li> a column with predicted class,
<li> a column with prediction probability.
</ul>
An example score file for the golf score data table is the following:
<pre>
1,Play,1
2,Don't Play,1
3,Don't Play,0.8
4,Play,1
5,Play,0.9
6,Play,1
</pre>
*/


/*! \page licence YaDT licence
<center>
<b>Version 1.2.5 (October 2010)</b><br>
<em>(c) Salvatore Ruggieri,2002-2010</em><br>
<a href="http://www.di.unipi.it/~ruggieri">http://www.di.unipi.it/~ruggieri</a>
</center>
<p>
	<P><B>[Copyright and licence of use]</B></P>
		<P>The YaDT (Yet another Decision Tree builder) software is copyright of SALVATORE
			RUGGIERI. By downloading the software, the user is granted a personal licence for
			research and/or educational use. The licence of
			the YaDT software DOES NOT include commercial use, either alone or as a part of
			other software.	</P>
	<P align="left"><STRONG>[Distribution] </STRONG>
	</P>
		<P align="left">The YaDT software cannot be distributed
			nor copied, all or in part. If used for educational purposes&nbsp;(eg. for
			classroom excercises), every user must download its own&nbsp;copy and agree on
			the licence terms.&nbsp;</P>
	<P align="left"><STRONG>[No warranty] </STRONG>
	</P>
	<p align="left">
			<P align="left">The YaDT software is distributed by the author "AS IS", WITHOUT
				WARRANTY OF ANY KIND, either expressed or implied, including but not limited to
				implied warranties of merchantability or fitness for a particular purpose. THE
				ENTIRE RISK AS TO QUALITY, PERFORMANCE, OR RESULTS DUE TO USE OF THE SOFTWARE
				IS ASSUMED BY THE USER, AND THE SOFTWARE IS PROVIDED WITHOUT SUPPORT OR
				OBLIGATION OF ANY KIND TO ASSIST IN ITS USE, MODIFICATION, OR ENHANCEMENT.<br>
			</P>
*/


#endif // !defined(_YADT_H__INCLUDED_)
