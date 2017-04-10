/*
			 Salvatore Ruggieri (c), 2002-
*/

#include <YaDT.h>
#include<cstdlib> 
#include<cstring> 
using namespace std;
using namespace yadt;

void USAGE()
{
	cout <<  yadt::get_copyright() << endl;
	cout << "Command line: dTcmd [doptions] [toptions] [ooption]" << endl;

	cout << " [doptions]: DataSet Options" << endl;
	cout << "    -f <file>   metadata in <file>.names and training data in <file>.data" << endl;
	cout << "    -fm <file>  metadata in <file> (*)" << endl;
	cout << "    -fd <file>  training data in <file> (*)" << endl;
	cout << "    -ft <file>  test data in <file> (*)" << endl;
	cout << "    -fs <file>  score data in <file> (*)" << endl;
	cout << "    -bd <file>  training data in binary format in <file>" << endl;
	cout << "    -sep <c>    column separator in files (default ',')" << endl;

	cout << " [toptions]: Tree Construction Options" << endl;
	cout << "    -bt <file>  No dataset. Tree binary input from <file>" << endl;
	cout << "    -c <num>    pruning confidence level -- must be in (0,1]" << endl;
	cout << "    -m <num>    minimum cases to split -- must be > 1" << endl;
	cout << "    -c4.5       true c4.5 pruning strategy (takes longer)" << endl;
	cout << "    -np         no pruning at all" << endl;
	cout << "    -h <num>    Holdout on training data: random <num>% as training and rest as test" << endl;
	cout << "    -hf <num>   Holdout on training data: first <num>% as training and rest as test" << endl;

	cout << " [ooptions]: Output Options" << endl;
	cout << "    -db <file>  training data binary output in <file>" << endl;
	cout << "    -tb <file>  tree binary output to <file>" << endl;
	cout << "    -l <file>   log output appended to <file>" << endl;
	cout << "    -t <file>   text output to <file>" << endl;
	cout << "    -x <file>   tree XML output to <file>" << endl;
	cout << "    -d <file>   tree DOT output to <file>" << endl;
	cout << "    -s <file>   score output to <file>" << endl;
	cout << "    -lstd       log output to stdout" << endl;
	cout << "    -tstd       text output to stdout" << endl;
	cout << "    -xstd       tree XML output to stdout" << endl;
	cout << "    -dstd       tree DOT output to stdout" << endl;
#if defined(__GNUC__)
	cout << " FastFlow options" << endl;
	cout << "    -ff <n> run using <n> core-CPU" << endl;
#endif
	cout << endl << "(*) .gz files are automatically gunzipped." << endl;
}

table* load_table(const string &separator, const string &metadataf, const string &dataf,
				  const string &metadatasqldb, const string &datasqldb,
				  const string &metadatasqltb, const string &datasqltb,
				  const string &databinaryf, ostream *outlog)
{
	if( databinaryf != string("") )
	{
		table *tb;

		try	{
			tb = table::fromBinary( databinaryf );
		}
		catch(...) {
			throw runtime_error("File " + databinaryf + ": not binary format" );
		}
		if( outlog != NULL )
			*outlog << "Data loaded." << endl;

		return tb;
	}

	table *tb = new table("training_set");

	if( metadataf != string("") )
		tb->load_meta_data( datasource(string("FILE#")+metadataf+"#"+separator) );
	else
		if( metadatasqltb != string("") )
			tb->load_meta_data(	datasource(string("SQL#"+metadatasqldb+"#"+metadatasqltb)) );
		else {
			cout << "No metadata provided." << endl;
			exit(0);
		}

// debug code
	tb->set_verbosity(200);
	tb->set_log(outlog);
// end debug code

	if( dataf != string("") ) 
		tb->load_data( datasource(string("FILE#")+dataf+"#"+separator) );
	else
		if( metadatasqltb != string("") )
			tb->load_data(	datasource(string("SQL#")+datasqldb+"#"+datasqltb) );
		else {
			cout << "No training data provided." << endl;
			exit(0);
		}

	if( outlog != NULL )
		*outlog << "Data loaded.\n time:  " << tb->get_elapsed() << " secs." << endl;
	return tb;
}

void save_table(table *tb,  const string &databinaryoutf,  ostream *outlog)
{
	if( databinaryoutf == string("") )
		return;

	try	{
		tb->toBinary(databinaryoutf);
	}
	catch(...) {
		throw runtime_error("File " + databinaryoutf + ": error with binary output" );
	}
	if( outlog != NULL )
		*outlog <<"Data saved." << endl;
}

pair<dtree *, table::subset *> 
	buildt(table *tb, double holdout, double holdoutf, float confidence, 
		   float minimum, dtree::PruningStrategy ps, int ff, ostream *outlog)
{
	dtree *tree = new dtree(tb->get_name());
	table::subset *trainingsubset = NULL;
	table::subset *testsubset = NULL;
	if( holdout > 0 && holdout < 1)
		trainingsubset = tb->get_wsubset_random( size_t(tb->get_no_rows() * holdout) );
	else if( holdoutf > 0 && holdoutf < 1)
		trainingsubset = tb->get_wsubset_first_n( size_t(tb->get_no_rows() * holdoutf) );

	tree->set_conf_level( confidence );
	tree->set_min_obj( minimum );
	tree->set_pruning_strategy( ps );
	tree->build(tb, trainingsubset, true, ff);

	if( outlog != NULL ) 
		*outlog << "Tree built." << endl 
				<< " size:  " << tree->size() 
				<< " depth: " << tree->depth() 
				<< " time:  " << tree->get_elapsed() << " secs." <<  endl;

	if( (holdout > 0 && holdout < 1) || (holdoutf > 0 && holdoutf < 1) ) {
		testsubset = tb->get_wsubset_difference( trainingsubset );
		delete trainingsubset;
	}

	return pair<dtree *, table::subset *>(tree, testsubset);
}

void save_tree(dtree *tree, string &treebinoutf, ostream *dotoutput, ostream *outlog)
{
	if( dotoutput!= NULL )
		tree->toDOT( *dotoutput );

	if( treebinoutf == string("") )
		return;

	try	{
		tree->toBinary(treebinoutf);
		if( outlog != NULL )
			*outlog <<"Tree saved." << endl;
	}
	catch(...) {
		throw runtime_error("File " + treebinoutf + ": error with binary output" );
	}
}


void test(table *tb, dtree *tree, const string &separator, string &testf, 
		  string &testsqldb, string &testsqltb, table::subset *vs, 
		  ostream *output, ostream *xmloutput, ostream *outputlog)
{

	// conf_matrix on training
	if( output != NULL ) {
		const conf_matrix *cm = tree->get_prediction();
		*output << yadt::get_copyright() << endl << endl
			<< "TREE SIZE: " << tree->size() << endl << endl
			<< "MISCLASSIFICATION on training: " 
			<< cm->mis_perc()*100 << "% of " << cm->cases() << " cases. " << endl;
		cm->toTEXT( *output );
		delete cm;
	}

	const conf_matrix *cm = NULL;

	// conf_matrix on sql server test data
	if( testsqltb != string("") ) {
		cm = tree->predict( datasource(string("SQL#")+testsqldb+"#"+testsqltb) );
		if( output != NULL ) {
			*output << endl << "MISCLASSIFICATION on test sqlserver: ";
			*output <<  cm->mis_perc()*100 << "% of " << cm->cases() << " cases. " << endl;
			cm->toTEXT( *output );
		}
		if( outputlog != NULL )
			*outputlog << "Testing done." << endl 
				<< " time:  " << cm->get_elapsed() << " secs." <<  endl;
	}

	// conf_matrix on test file data
	if( testf != string("") ) {
		cm = tree->predict( datasource(string("FILE#")+testf+"#"+separator) );
		if( output != NULL ) {
			*output << endl << "MISCLASSIFICATION on test file: ";
			*output <<  cm->mis_perc()*100 << "% of " << cm->cases() << " cases. " << endl;
			cm->toTEXT( *output );
		}
		if( outputlog != NULL )
			*outputlog << "Testing done." << endl 
				<< " time:  " << cm->get_elapsed() << " secs." <<  endl;
	}

	// conf_matrix on hold out data
	if( vs != NULL ) {
		cm = tree->predict(tb, vs );
		if( output != NULL ) {
			*output << endl << "MISCLASSIFICATION on holdout test: "
				<< cm->mis_perc()*100 << "% of " << cm->cases() << " cases. " << endl;
			cm->toTEXT( *output );
		}
		if( outputlog != NULL )
			*outputlog << "Testing done." << endl 
				<< " time:  " << cm->get_elapsed() << " secs." <<  endl;
	}

	if( output != NULL ) {
		*output << endl << "Decision Tree" << endl << endl;
		tree->toTEXT(*output);
	}

	if( xmloutput!= NULL )
		tree->toXML( *xmloutput, cm );

	if( cm != NULL )
		delete cm;

}

void evaluate(dtree *tree,  const string &separator,
			  const string &valinf, const string &valoutf,
			  const string &valsqldb, const string &valsqltb, ostream *outlog )
{
	if( valinf == string("") && valsqltb == string("") )
		return;

	if( valoutf == string("") ) {
		if( outlog != NULL)
			*outlog << endl << "No score output file provided!" << endl << endl;
		return;
	}

	ofstream valoutput( valoutf.c_str() );
	double elapsed = 0;

	if( valsqltb != string("") ) {
		elapsed = tree->evaluate( datasource(string("SQL#")+valsqldb+"#"+valsqltb), valoutput, separator[0] );
		if( outlog != NULL )
			*outlog << "Evaluation done." << endl << " time:  " << elapsed << " secs." <<  endl;
	}

	if( valinf != string("") ) {
		elapsed = tree->evaluate( datasource(string("FILE#")+valinf+"#"+separator), valoutput, separator[0] );
		if( outlog != NULL )
			*outlog << "Evaluation done." << endl << " time:  " << elapsed << " secs." <<  endl;
	}

}

int main(int argc, char *argv[])
{
	if( argc == 1 ) {
		USAGE();
		exit(0);
	}

	string separator = ",";
	string metadataf, dataf, testf, valinf,valoutf;
	string databinaryf, databinaryoutf;
	string metadatasqldb, datasqldb, testsqldb, valsqldb;
	string metadatasqltb, datasqltb, testsqltb, valsqltb;
	string textf, xmlf, dotf, logf, treebininf, treebinoutf, databinf;
	bool textstd = false, logstd = false, xmlstd = false, dotstd = false;
	int ff = 0;

	float confidence = 0.25, minimum = 2;
	dtree::PruningStrategy ps = dtree::PRUNING_DT;
	double holdout = 0, holdoutf = 0;

	int i = 0;
	while(++i < argc) {

		// Dataset Options
		if( !strcmp(argv[i], "-f") ) {
			metadataf = string(argv[++i]) + ".names";
			dataf = string(argv[i]) + ".data";
			continue;
		}

		if( !strcmp(argv[i], "-fm") ) {
			metadataf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-fd") ) {
			dataf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-ft") ) {
			testf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-fs") ) {
			valinf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-bd") ) {
			databinaryf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-db") ) {
			databinaryoutf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-sep") ) {
			separator = string(argv[++i]);
			continue;
		}

		// Tree Construction Options
		if( !strcmp(argv[i], "-tb") ) {
			treebinoutf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-bt") ) {
			treebininf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-h") ) {
			holdout = atof(argv[++i])/100;
			if( holdout <= 0 || holdout > 1 ) {
				cout << "Holdout must be in (0,100]" << endl;
				exit(-1);
			}
			continue;
		}

		if( !strcmp(argv[i], "-hf") ) {
			holdoutf = atof(argv[++i])/100;
			if( holdoutf <= 0 || holdoutf > 1 ) {
				cout << "Holdout must be in (0,100]" << endl;
				exit(-1);
			}
			continue;
		}

		if( !strcmp(argv[i], "-m") ) {
			minimum = atof(argv[++i]);
			if( minimum <= 1 ) {
				cout << "MinObjects must be > 1" << endl;
				exit(-1);
			}
			continue;
		}

		if( !strcmp(argv[i], "-c") ) {
			confidence = atof(argv[++i]);
			if( confidence <= 0 || confidence > 1 ) {
				cout << "Confidence level must be in (0,1]" << endl;
				exit(-1);
			}
			continue;
		}

		if( !strcmp(argv[i], "-c4.5") ) {
			ps = dtree::PRUNING_C45;
			continue;
		}

		if( !strcmp(argv[i], "-np") ) {
			ps = dtree::PRUNING_NO;
			continue;
		}

		// Output Options
		if( !strcmp(argv[i], "-tstd") ) {
			textstd = true;
			continue;
		}

		if( !strcmp(argv[i], "-lstd") ) {
			logstd = true;
			continue;
		}

		if( !strcmp(argv[i], "-xstd") ) {
			xmlstd = true;
			continue;
		}

		if( !strcmp(argv[i], "-dstd") ) {
			dotstd = true;
			continue;
		}

		if( !strcmp(argv[i], "-s") ) {
			valoutf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-t") ) {
			textf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-l") ) {
			logf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-x") ) {
			xmlf = string(argv[++i]);
			continue;
		}

		if( !strcmp(argv[i], "-d") ) {
			dotf = string(argv[++i]);
			continue;
		}

#if defined(__GNUC__)
		// FastFlow options
		if( !strcmp(argv[i], "-ff") ) {
			int ncpu = sysconf(_SC_NPROCESSORS_ONLN);
			ff = atoi(argv[++i]);
			if( ff < 1 || ff > ncpu ) {
  			        cout << "<n> must be in [1," << ncpu << "]" << endl;
				exit(-1);
			}
			continue;
		}
#endif

		// Otherwise ...
		cout << "Unknown command: " << argv[i] << endl;
		exit(-1);
	} // while( i < argc )

	try {
		// output streams
		ostream *outlog = logstd ? &cout : NULL;
		if( logf != string("") )
			outlog = new ofstream( logf.c_str(), ios::app );

		ostream *output = textstd ? &cout : NULL;
		if( textf != string("") )
			output = new ofstream( textf.c_str() );

		ostream *xml = xmlstd ? &cout : NULL;
		if( xmlf != string("") )
			xml = new ofstream( xmlf.c_str() );

		ostream *dot = dotstd ? &cout : NULL;
		if( dotf != string("") )
			dot = new ofstream( dotf.c_str() );

		// training table and decision tree
		table *tb = NULL;
		dtree *tree = NULL;
		table::subset *testsubset = NULL;
		if( treebininf == string("") ) {
			tb = load_table(separator, metadataf, dataf, metadatasqldb, datasqldb,
				metadatasqltb, datasqltb, databinaryf, outlog );
			save_table(tb, databinaryoutf, outlog );
			pair<dtree *, table::subset *> treebuilt = 
				buildt(tb, holdout, holdoutf, confidence, minimum, ps, ff, outlog);
			tree = treebuilt.first;
			testsubset = treebuilt.second;
		} else {
			// binary load
			tree = dtree::fromBinary(treebininf);
			if( outlog != NULL )
				*outlog << "Tree loaded." << endl;
		}
		save_tree(tree, treebinoutf, dot, outlog);
		test(tb, tree,  separator, testf, testsqldb, testsqltb, testsubset, output, xml, outlog);
		evaluate(tree, separator, valinf, valoutf, valsqldb, valsqltb, outlog);

		delete tb;
		delete tree;
	}
	catch(runtime_error e) {
		cout << e.what() << endl;
	}
	catch(...) {
		cout << "Halting on generic error." << endl;
	}

	return 0;
}
