from mars.session import new_session
ray_session = new_session(backend='ray', log_to_driver=False).as_default()

import mars.dataframe as md
import mars.tensor as mt

t = mt.random.rand(100, 4, chunk_size=30)
df = md.DataFrame(t, columns=list('abcd'))
print(df.describe().execute())
