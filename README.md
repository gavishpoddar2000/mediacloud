MediaCloud Python API Client
============================

This is the source code of the python MediaCloud API client module.  This client is still 
*under construction*, because so is the API.

Installation
------------

Download the distribution zip, then run

    python setup.py install

Install and run [CouchDB](http://couchdb.apache.org) or [MongoDb](http://mongodb.org) to store 
article info.

*Dependencies*

```
pip install pypubsub
```

Examples
--------

Get a list of all the sentences from the US mainstream media that mentioned "Zimbabwe" and "president" in 2013:
```python
import mediacloud
mc = mediacloud.api.MediaCloud('MY_USERNAME','MY_PASSWORD')
res = mc.sentencesMatching('( zimbabwe AND president)', '+publish_date:[2013-01-01T00:00:00Z TO 2013-12-31T00:00:00Z] AND +media_sets_id:1')
print res['response']['numFound']
```

Find the most commonly used words in sentences from the US mainstream media that mentioned "Zimbabwe" and "president" in 2013:
```python
import mediacloud
mc = mediacloud.api.MediaCloud('MY_USERNAME','MY_PASSWORD')
res = mc.wordCount('( zimbabwe AND president)', '+publish_date:[2013-01-01T00:00:00Z TO 2013-12-31T00:00:00Z] AND +media_sets_id:1')
print res[0]
```

Take a look at the `apitest.py` for more info.

Testing
-------

First run all the tests.  Copy `mc-client.config.template` to `mc-client.config` and edit it.
Then run `python tests.py`.

Notice you get a `mediacloud-api.log` that tells you about each query it runs.

Distribution
------------

To build the distributon, run `python setup.py sdist` and a compressed file will be created in 
the `dist` directory.
