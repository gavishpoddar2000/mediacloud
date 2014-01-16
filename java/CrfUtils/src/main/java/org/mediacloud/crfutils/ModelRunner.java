package org.mediacloud.crfutils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.Reader;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.regex.Pattern;

import cc.mallet.fst.CRF;
import cc.mallet.fst.SimpleTagger;
import cc.mallet.pipe.Pipe;
import cc.mallet.pipe.iterator.LineGroupIterator;
import cc.mallet.types.InstanceList;
import cc.mallet.types.Sequence;

public class ModelRunner {

    private final CRF crf;

    public ModelRunner(String modelFileName) throws IOException,
            FileNotFoundException, ClassNotFoundException {

        ObjectInputStream s = new ObjectInputStream(new FileInputStream(
                modelFileName));
        crf = (CRF) s.readObject();
        s.close();
    }

    public String[] runModel(String testFileName) throws Exception {

        InstanceList testData = readTestData(testFileName);
        return runCrfModel(testData);
    }

    public String[] runModelString(String testDataString) throws Exception {

        InstanceList testData = readTestDataFromString(testDataString);
        return runCrfModel(testData);
    }

    private String[] runCrfModel(InstanceList testData) {

        if (true) {
            Runtime rt = Runtime.getRuntime();

            System.err.println("Used Memory: " + (rt.totalMemory() - rt.freeMemory()) / 1024 + " KB");
            System.err.println("Free Memory: " + rt.freeMemory() / 1024 + " KB");
            System.err.println("Total Memory: " + rt.totalMemory() / 1024 + " KB");
            System.err.println("Max Memory: " + rt.maxMemory() / 1024 + " KB");
        }

        ArrayList<String> results = new ArrayList<String>();
        for (int i = 0; i < testData.size(); i++) {
            Sequence input = (Sequence) testData.get(i).getData();

            ArrayList<String> predictions = predictSequence(input);

            results.addAll(predictions);
        }

        return results.toArray(new String[0]);
    }

    private InstanceList readTestData(String testFileName) throws FileNotFoundException {

        Reader testFile = new FileReader(new File(testFileName));
        return instanceListFromReader(testFile);
    }

    private InstanceList readTestDataFromString(final String testData) {

        Reader testFile = new StringReader(testData);
        return instanceListFromReader(testFile);
    }

    private InstanceList instanceListFromReader(Reader testFile) {

        Pipe p = crf.getInputPipe();
        p.setTargetProcessing(false);
        InstanceList testData = new InstanceList(p);
        testData.addThruPipe(
                new LineGroupIterator(testFile,
                        Pattern.compile("^\\s*$"), true));
        return testData;
    }

    private ArrayList<String> predictSequence(Sequence input) {

        int nBestOption = 1;

        Sequence[] outputs = SimpleTagger.apply(crf, input, nBestOption);
        int k = outputs.length;

        try {
            for (int a = 0; a < k; a++) {
                if (outputs[a].size() != input.size()) {
                    throw new RuntimeException("Failed to decode input sequence " + input + ", answer " + a);
                }
            }
        } catch (RuntimeException e) {
            System.err.println("Exception: " + e.getMessage());
            return new ArrayList<String>();
        }

        ArrayList<String> sequenceResults = new ArrayList<String>();
        for (int j = 0; j < input.size(); j++) {
            for (int a = 0; a < k; a++) {
                String prediction = outputs[a].get(j).toString();
                sequenceResults.add(prediction + " ");
            }
        }

        return sequenceResults;
    }
}
